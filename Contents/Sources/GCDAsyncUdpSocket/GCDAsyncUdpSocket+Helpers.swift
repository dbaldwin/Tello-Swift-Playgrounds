//
//  GCDAsyncUdpSocket+Helpers.swift
//  GCDAsyncUdpSocket-Swift
//
//  Created by XIAOWEI WANG on 18/05/2018.
//  Copyright © 2018 XIAOWEI WANG(mooosu@hotmail.com).
//  Inspired by CocoaAsyncSocket.
//  All rights reserved.
//



import Foundation
import Dispatch
import Darwin.TargetConditionals
import Darwin.Availability

extension GCDAsyncUdpSocket {
    class var sockaddr_size: Int {
        return MemoryLayout<sockaddr>.size
    }

    class var sockaddr_in_size: Int {
        return MemoryLayout<sockaddr_in>.size
    }

    class var sockaddr_in4_size : Int {
        return MemoryLayout<sockaddr_in>.size
    }

    class var sockaddr_in6_size : Int {
        return MemoryLayout<sockaddr_in6>.size
    }

    class var in6_addr_size : Int {
        return MemoryLayout<in6_addr>.size
    }
    
    static func checkPortibility() {
        /* x86_64, x86
         sockaddr_size    : 16
         sockaddr_in_size : 16
         sockaddr_in4_size: 16
         sockaddr_in6_size: 28
         in6_addr_size    : 16
        */
        assert(sockaddr_size     == 16)
        assert(sockaddr_in_size  == 16)
        assert(sockaddr_in4_size == 16)
        assert(sockaddr_in6_size == 28)
        assert(in6_addr_size     == 16)
    }

    func runSyncWithoutReturnValue(block: () throws -> Void) throws {
        if( DispatchQueue.getSpecific(key: _IsOnSocketQueueOrTargetQueueKey) != nil) {
            try block()
        } else {
            try _socketQueue!.sync(execute: block)
        }
    }
    
    func runSyncWithReturnValue(block: () -> Any?) -> Any? {
        var result : Any?
        if( DispatchQueue.getSpecific(key: _IsOnSocketQueueOrTargetQueueKey) != nil) {
            result = block()
        } else {
            result = _socketQueue!.sync(execute: block)
        }
        return result
    }

    func runBlockSyncSafely(block: () -> Void) {
        if( DispatchQueue.getSpecific(key: _IsOnSocketQueueOrTargetQueueKey) != nil) {
            block()
        } else {
            _socketQueue!.sync(execute: block)
        }
    }
    
    func runBlockAsyncSafely(block: @escaping () -> Void) {
        if( DispatchQueue.getSpecific(key: _IsOnSocketQueueOrTargetQueueKey) != nil) {
            block()
        } else {
            _socketQueue.async {
                block()
            }
        }
    }
    
    func maybeUpdateCachedLocalAddress4Info() {
        assert( self.isSocketQueue, "Must be dispatched on socketQueue")
        if _cachedLocalAddress4 != nil || !didBind || _socket4FD == InvalidSocket {
            return
        }
        
        (_cachedLocalAddress4, _cachedLocalHost4, _cachedLocalPort4) =
            GCDAsyncUdpSocket.getLocalAddress(socketFD: self.socket4FD, family: AF_INET)
    }
    
    func maybeUpdateCachedLocalAddress6Info() {
        assert( self.isSocketQueue, "Must be dispatched on socketQueue")
        if _cachedLocalAddress6 != nil || !didBind || _socket6FD == InvalidSocket {
            return
        }
        
        (_cachedLocalAddress6, _cachedLocalHost6, _cachedLocalPort6) =
            GCDAsyncUdpSocket.getLocalAddress(socketFD: self.socket6FD, family: AF_INET6)
    }

    func isConnectedToAddress4(someAddr: Data?) -> Bool {
        guard let addr = someAddr, let addr2 = self._cachedConnectedAddress, _cachedConnectedFamily == AF_INET else {
            return false
        }
        
        assert( self.isSocketQueue, "Must be dispatched on socketQueue")
        assert( self.isConnected, "Not connected");
        assert( self._cachedConnectedAddress != nil, "Expected cached connected address");
        
        return GCDAsyncUdpSocket.compareSockaddrIn4(addr1: addr, addr2: addr2)
    }
    
    func isConnectedToAddress6(someAddr: Data?) -> Bool {
        guard let addr = someAddr,
            let addr2 = self._cachedConnectedAddress,
            _cachedConnectedFamily == AF_INET6 else {
                return false
        }
        
        assert( (DispatchQueue.getSpecific(key: _IsOnSocketQueueOrTargetQueueKey) != nil), "Must be dispatched on socketQueue")
        assert( self.isConnected, "Not connected");
        assert( self._cachedConnectedAddress != nil, "Expected cached connected address");
        
        return GCDAsyncUdpSocket.compareSockaddrIn6(addr1: addr, addr2: addr2)
    }
    
    class func errorMessageWithReason(reason: String?) -> String {
        let err = errno
        let errMsg = String(cString: strerror(err))
        return String(format: "Code: %d, Description: %@, Message: %@", err, reason ?? "", errMsg)
    }
    
    class func buildErrorWithReason(reason: String) -> NSError {
        let no = errno
        let errMsg = String(cString: strerror(no))
        let userInfo = [
            NSLocalizedDescriptionKey : errMsg,
            NSLocalizedFailureReasonErrorKey: reason
        ]
        return NSError(domain: NSPOSIXErrorDomain, code: Int(no), userInfo: userInfo)
    }
    
    class func buildLoopbackAddresses(port: UInt16) -> (Data, Data) {
        let sockaddr4 = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
        defer {
            sockaddr4.deallocate()
        }
        memset(sockaddr4, 0, sockaddr_in_size)
        
        sockaddr4.pointee.sin_len         = __uint8_t(sockaddr_in_size)
        sockaddr4.pointee.sin_family      = sa_family_t(AF_INET)
        sockaddr4.pointee.sin_port        = _OSSwapInt16(port)
        sockaddr4.pointee.sin_addr.s_addr = _OSSwapInt32(INADDR_LOOPBACK)
        
        let sockaddr6 = UnsafeMutablePointer<sockaddr_in6>.allocate(capacity: 1)
        defer {
            sockaddr6.deallocate()
        }
        memset(sockaddr6, 0, sockaddr_in6_size)
        
        sockaddr6.pointee.sin6_len         = __uint8_t(sockaddr_in6_size)
        sockaddr6.pointee.sin6_family      = sa_family_t(AF_INET6)
        sockaddr6.pointee.sin6_port        = _OSSwapInt16(port)
        
        var a6 = in6addr_loopback
        memcpy(&sockaddr6.pointee.sin6_addr, &a6, in6_addr_size)
        
        let addr4 = Data(bytes: sockaddr4, count: sockaddr_in_size)
        let addr6 = Data(bytes: sockaddr6, count: sockaddr_in6_size)
        return (addr4, addr6)
    }
    
    func asyncResolveHost(host: String, port: UInt16, block: @escaping ( [Data]?, Error?) -> Void) {
        var error: SocketError? = nil
        if host.isEmpty {
            self._socketQueue.async {
                error = SocketError.OtherError("Host Can't be empty")
                block(nil, error)
            }
        }

        let queue = DispatchQueue.global(qos: .default)
        queue.async {
            var addresses = [Any]()
            if host == "localhost" || host == "loopback" {
                let (addr4, addr6) = type(of: self).buildLoopbackAddresses(port: port)
                addresses.append(addr4)
                addresses.append(addr6)
            } else {
                var listp: addrinfo_pointer? = nil
                var hints: addrinfo = addrinfo()
                let portString = String(format: "%u", port)

                hints.ai_family = PF_UNSPEC
                hints.ai_socktype = SOCK_DGRAM
                hints.ai_protocol = IPPROTO_UDP
                
                if getaddrinfo(host, portString, &hints, &listp) == 0 {
                    var ai_count = 0
                    var p: addrinfo_pointer? = listp
                    while( p != nil ) {
                        if p!.pointee.ai_family == AF_INET {
                            addresses.append(Data.init(bytes: p!.pointee.ai_addr, count: Int(p!.pointee.ai_addrlen)))
                        } else if p!.pointee.ai_family == AF_INET6 {
                            let addr_in6 = UnsafeMutablePointer<sockaddr_in6>.allocate(capacity: 1)
                            defer {
                                addr_in6.deallocate()
                            }
                            p!.withMemoryRebound(to: sockaddr_in6.self, capacity: 1, { (pointer) in
                                addr_in6.assign(from: pointer, count: 1)
                                if pointer.pointee.sin6_port == 0 {
                                    pointer.pointee.sin6_port = _OSSwapInt16(port)
                                }
                                addresses.append(Data.init(bytes: p!.pointee.ai_addr, count: Int(p!.pointee.ai_addrlen)))
                            })
                        }
                        ai_count += 1
                        p = p!.pointee.ai_next
                    }
                    freeaddrinfo(listp);
                    if addresses.isEmpty {
                        error = SocketError.OtherError("Can't get the addresses")
                    }
                }
            }
            
            self._socketQueue.async {
                block(addresses as? [Data], error)
            }
            
        }
    }
}

