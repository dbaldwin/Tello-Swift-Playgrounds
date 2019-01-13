//
//  SimplePing.swift
//  SimplePing
//
//  Created by XIAOWEI WANG on 2018/8/13.
//  Inspired by Apple Inc.
//  Copyright © 2018 XIAOWEI WANG. All rights reserved.
//

import Foundation


struct ICMPHeader {
    static var size: Int {
        assert(MemoryLayout<ICMPHeader>.size == 8)
        return MemoryLayout<ICMPHeader>.size
    }
    var type: UInt8
    var code: UInt8
    var checksum: UInt16
    var identifier: UInt16
    var sequenceNumber: UInt16
    // data...
};

struct IPHeader {
    static var size: Int {
        assert(MemoryLayout<IPHeader>.size == 20)
        return MemoryLayout<IPHeader>.size
    }
    var versionAndHeaderLength: UInt8
    var differentiatedServices: UInt8
    var totalLength: UInt16
    var identification: UInt16
    var flagsAndFragmentOffset: UInt16
    var timeToLive: UInt8
    var protocol_: UInt8
    var headerChecksum: UInt16
    var sourceAddress1: UInt8
    var sourceAddress2: UInt8
    var sourceAddress3: UInt8
    var sourceAddress4: UInt8
    var destinationAddress1: UInt8
    var destinationAddress2: UInt8
    var destinationAddress3: UInt8
    var destinationAddress4: UInt8
    // options...
    // data...
};


protocol SimplePingDelegate {
    func simplePing( pinger: SimplePing, didStartWithAddress address: Data )
    func simplePing( pinger: SimplePing, didFailWithError error: NSError? )
    func simplePing( pinger: SimplePing, didSendPacket packet: Data )
    func simplePing( pinger: SimplePing, didFailToSendPacket packet: Data, error: NSError? )
    func simplePing( pinger: SimplePing, didReceivePingResponsePacket packet: Data )
    func simplePing( pinger: SimplePing, didReceiveUnexpectedPacket packet: Data )
}

enum ICMPType: UInt8 {
    case EchoReply   = 0
    case EchoRequest = 8
}

class SimplePing: NSObject {
    var _hostName: String? = nil
    var _hostAddress: Data? = nil
    var _delegate: SimplePingDelegate? = nil
    var _identifier : UInt16 = 0
    var _nextSequenceNumber : UInt16 = 0
    
    var _host : CFHost? = nil
    var _socket: CFSocket? = nil

    init(hostName: String?, hostAddress: Data?) {
        assert( ( hostName != nil) == (hostAddress == nil))
        self._hostName = hostName
        self._hostAddress = hostAddress
        self._identifier  = UInt16(arc4random() & 0xffff)
    }

    convenience init(hostName: String) {
        self.init(hostName: hostName, hostAddress: nil)
    }
    
    convenience init(hostAddress: Data) {
        self.init(hostName: nil, hostAddress: hostAddress)
    }
    
    deinit {
        self.stop()
        self._host = nil
        self._socket = nil
    }

    @objc func noop() {
    }

    func didFail(withError error: NSError) {
        // We retain ourselves temporarily because it's common for the delegate method
        // to release its last reference to use, which causes -dealloc to be called here.
        // If we then reference self on the return path, things go badly.  I don't think
        // that happens currently, but I've got into the habit of doing this as a
        // defensive measure.
        
        self.perform(#selector(SimplePing.noop), with: nil, afterDelay: 0.0)
        self.stop()

        if let delegate = self._delegate {
            delegate.simplePing(pinger: self, didFailWithError: error)
        }
    }

    func didFail(withHostStreamError streamError: CFStreamError ) {
        var userInfo: NSDictionary? = nil
        if streamError.domain == kCFStreamErrorDomainNetDB {
            userInfo = NSDictionary(dictionaryLiteral: (kCFGetAddrInfoFailureKey, streamError.error))
        }
        let error = NSError(
            domain: kCFErrorDomainCFNetwork as String,
            code: Int(CFNetworkErrors.cfHostErrorUnknown.rawValue), userInfo: userInfo as? [String : Any])
        self.didFail(withError: error)
    }

    func sendPingWithData( data: Data? = nil) {
        var err: Int32 = 0
        var bytesSent = 0
        var payload: Data
        if data == nil {
            payload = String(format: "%28zd bottles of beer on the wall", ssize_t(99) - size_t(self._nextSequenceNumber % 100))
                .data(using: .ascii)!
        } else {
             payload = data!
        }
        assert(payload.count == 56)
        
        let packetSize = ICMPHeader.size + payload.count
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: packetSize)
        defer {buffer.deallocate() }

        buffer.withMemoryRebound(to: ICMPHeader.self, capacity: 1) { (icmpHeader) -> Void in
            icmpHeader.pointee.type = ICMPType.EchoRequest.rawValue
            icmpHeader.pointee.code = 0
            icmpHeader.pointee.checksum = 0
            icmpHeader.pointee.identifier =  CFSwapInt16HostToBig( self._identifier)
            icmpHeader.pointee.sequenceNumber = CFSwapInt16HostToBig( self._nextSequenceNumber)
        }
        payload.copyBytes(to: buffer.advanced(by: MemoryLayout<ICMPHeader>.size), count: payload.count)
        
        var bytes = [UInt8](repeating: 0, count: packetSize)
        memcpy(&bytes[0],buffer, packetSize);

        buffer.withMemoryRebound(to: ICMPHeader.self, capacity: 1) { (icmpHeader) -> Void in
            
            // The IP checksum returns a 16-bit number that's already in correct byte order
            // (due to wacky 1's complement maths), so we just put it into the packet as a
            // 16-bit unit.
            
            icmpHeader.pointee.checksum = SimplePing.in_cksum(data: bytes)
        }

        let sock = CFSocketGetNative(self._socket)
        var tv = timeval(tv_sec: 0, tv_usec: 10000) // 0.1 sec
        setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, &tv, socklen_t(MemoryLayout.size(ofValue: tv)))

        if self._socket == nil {
            bytesSent = -1;
            err = EBADF
        } else {
            _hostAddress!.withUnsafeBytes({ (addr: UnsafePointer<sockaddr>) -> Void in
                bytesSent = sendto(sock, buffer, packetSize, 0, addr, socklen_t(_hostAddress!.count))
                if bytesSent < 0 {
                    err = errno
                }
            })
        }

        let packet = Data(bytes: bytes)
        if bytesSent > 0 && bytesSent == packetSize {
            // Complete success.
            if let delegate = self._delegate {
                delegate.simplePing(pinger: self, didSendPacket: packet)
            }
        } else {
            if (err == 0) {
                err = ENOBUFS;          // This is not a hugely descriptor error, alas.
            }
            let error = NSError(domain: NSPOSIXErrorDomain, code: Int(err), userInfo: nil)
            if let delegate = self._delegate {
                delegate.simplePing(pinger: self, didFailToSendPacket: packet, error: error)
            }
        }
        self._nextSequenceNumber += 1
    }

    static func icmpHeaderOffsetInPacket(packet: Data) -> Int {
        var ipHeaderLength = 0
        var result = NSNotFound

        if packet.count > (IPHeader.size + ICMPHeader.size) {
            packet.withUnsafeBytes { (ipheader: UnsafePointer<IPHeader>) -> Void in
                assert((ipheader.pointee.versionAndHeaderLength & 0xF0) == 0x40)      // IPv4
                assert(ipheader.pointee.protocol_ == 1)                               // ICMP
                ipHeaderLength = (Int(ipheader.pointee.versionAndHeaderLength) & 0x0F) * MemoryLayout<UInt32>.size
                if packet.count >= (ipHeaderLength + ICMPHeader.size) {
                    result = ipHeaderLength
                }
            }
        }
        return result
    }

    static func icmpInPacket(packet: Data) -> ICMPHeader {
        var header = ICMPHeader(type: 1, code: 1, checksum: 1, identifier: 1, sequenceNumber: 1)
        let icmpHeaderOffset = icmpHeaderOffsetInPacket(packet: packet)
        if icmpHeaderOffset != NSNotFound {
            packet.withUnsafeBytes { (pointer: UnsafePointer) -> Void in
                memcpy(&header, pointer + icmpHeaderOffset, ICMPHeader.size)
            }
        }
        return header
    }

    func isValidPingResponsePacket(packet: Data) -> Bool {
        var result = false
        let icmpHeaderOffset = type(of: self).icmpHeaderOffsetInPacket(packet: packet)
        if icmpHeaderOffset != NSNotFound {
            let count = packet.count - icmpHeaderOffset
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
            defer {
                buffer.deallocate()
            }
            for i in 0..<count {
                buffer[i] = packet[i+icmpHeaderOffset]
            }

            var receivedChecksum: UInt16 = 0
            buffer.withMemoryRebound(to: ICMPHeader.self, capacity: 1) { (icmpHeader) -> Void in
                receivedChecksum = icmpHeader.pointee.checksum
                icmpHeader.pointee.checksum = 0
            }

            var bytes = [UInt8](repeating: 0, count: count)
            memcpy(&bytes[0],buffer, count);

            let calculatedChecksum = type(of: self).in_cksum(data: bytes)
            if (receivedChecksum == calculatedChecksum) {
                buffer.withMemoryRebound(to: ICMPHeader.self, capacity: 1) { (icmpHeader) -> Void in
                    icmpHeader.pointee.checksum = receivedChecksum
                    result = (icmpHeader.pointee.type == ICMPType.EchoReply.rawValue) &&
                        (icmpHeader.pointee.code == 0) &&
                        (CFSwapInt16BigToHost(icmpHeader.pointee.identifier) == self._identifier) &&
                        (CFSwapInt16BigToHost(icmpHeader.pointee.sequenceNumber) < self._nextSequenceNumber)
                }
            }
        }
        return result
    }

    func readData() {
        var addr = UnsafeMutablePointer<sockaddr_storage>.allocate(capacity: 1)
        defer { addr.deallocate() }

        var addrLen: socklen_t = 0
        let bufferSize = 65535
        var buffer = [UInt8].init(repeating: 0, count: bufferSize)
        let bytesRead = addr.withMemoryRebound(to: sockaddr.self, capacity: 1) { (pointer: UnsafeMutablePointer<sockaddr>) -> Int in
            return recvfrom(CFSocketGetNative(self._socket), &buffer[0], bufferSize, 0, pointer, &addrLen);
        }

        var err: Int32 = bytesRead < 0 ? errno : 0

        if (bytesRead > 0) {
            let packet = Data(bytes: buffer, count: bytesRead)
            // We got some data, pass it up to our client.
            if self.isValidPingResponsePacket(packet: packet) {
                if let delegate = self._delegate {
                    delegate.simplePing(pinger: self, didReceivePingResponsePacket: packet)
                }
            } else {
                if let delegate = self._delegate {
                    delegate.simplePing(pinger: self, didReceiveUnexpectedPacket: packet)
                }
            }
        } else {
            // We failed to read the data, so shut everything down.
            if (err == 0) {
                err = EPIPE
            }
            self.didFail(withError: NSError(domain: NSPOSIXErrorDomain, code: Int(err), userInfo: nil))
        }
    }

    func startWithHostAddress() {
        var err: Int32 = 0
        var fd: Int32 = -1
        self._hostAddress!.withUnsafeBytes { (addr: UnsafePointer<sockaddr>) -> Void in
            switch Int32(addr.pointee.sa_family) {
            case AF_INET:
                fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP)
            case AF_INET6:
                assert(false)
            default:
                err = EPROTONOSUPPORT
            }
        }
        if err != 0 {
            self.didFail(withError: NSError(domain: NSPOSIXErrorDomain, code: Int(err), userInfo: nil))
        } else {
            var context = CFSocketContext(version: 0, info: unsafeBitCast(self, to: UnsafeMutableRawPointer.self), retain: nil, release: nil, copyDescription: nil)
            var rls: CFRunLoopSource? = nil

            self._socket = CFSocketCreateWithNative(nil, fd, CFSocketCallBackType.readCallBack.rawValue, { (socket, type, address, data, info) in
                SimplePing.SocketReadCallback(s: socket, type: type, address: address, data: data, info: info)
            }, &context)

            // The socket will now take care of cleaning up our file descriptor.

            assert( (CFSocketGetSocketFlags(self._socket) & kCFSocketCloseOnInvalidate) != 0 );
            
            fd = -1;
            
            rls = CFSocketCreateRunLoopSource(nil, self._socket, 0);
            assert(rls != nil);
            CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, CFRunLoopMode.defaultMode);
            
            if let delegate = self._delegate {
                delegate.simplePing(pinger: self, didStartWithAddress: self._hostAddress!)
            }
        }
        assert(fd == -1)
    }
    
    func hostResolutionDone() {
        var resolved: DarwinBoolean = false
        var addressResolved = false
        guard let addresses = CFHostGetAddressing(self._host!, &resolved), resolved.boolValue else {
            return
        }
        let IPs = (addresses.takeUnretainedValue() as NSArray).compactMap { $0 as? Data }
        for address in IPs {
            address.withUnsafeBytes { (addr: UnsafePointer<sockaddr>) -> Void in
                if addr.pointee.sa_family == AF_INET {
                    self._hostAddress = address
                    addressResolved = true
                }
            }
            if addressResolved {
                break
            }
        }
        
        self.stopHostResolution()
        if addressResolved {
            self.startWithHostAddress()
        } else {
            self.didFail(withError: NSError(
                domain: kCFErrorDomainCFNetwork as String,
                code: Int(CFNetworkErrors.cfHostErrorHostNotFound.rawValue), userInfo: nil))
            
        }
    }

    func start() {
        if self._hostAddress != nil {
            self.startWithHostAddress()
        } else {
            assert(self._host == nil)
            
            var success = false
            var streamError = CFStreamError(domain: 0, error: 0)
            var context = CFHostClientContext(
                version: 0, info: unsafeBitCast(self, to: UnsafeMutableRawPointer.self),
                retain: nil, release: nil, copyDescription: nil)
            
            self._host = CFHostCreateWithName(nil, self._hostName! as CFString).takeRetainedValue()
            
            assert(self._host != nil)

            CFHostSetClient(self._host!, { (host, infoType, error, info) in
                SimplePing.HostResolveCallback(theHost: host, typeInfo: infoType, error: error, info: info)
            }, &context)

            CFHostScheduleWithRunLoop(self._host!, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue);
            success = CFHostStartInfoResolution(self._host!, CFHostInfoType.addresses, &streamError)
            if !success {
                self.didFail(withHostStreamError: streamError)
            }
        }
    }

    func stopHostResolution() {
        if (self._host != nil) {
            CFHostSetClient(self._host!, nil, nil);
            CFHostUnscheduleFromRunLoop(self._host!, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue);
            self._host = nil;
        }
    }
    
    func stopDataTransfer() {
        if (self._socket != nil) {
            CFSocketInvalidate(self._socket);
            self._socket = nil;
        }
    }
    
    
    func stop() {
        self.stopHostResolution()
        self.stopDataTransfer()
        
        if self._hostName != nil {
            self._hostAddress = nil
        }
    }
}
