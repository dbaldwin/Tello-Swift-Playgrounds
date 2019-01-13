//
//  GCDAsyncUdpSocket+SendingSockets.swift
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


fileprivate var sockaddr_in_size: Int {
    return MemoryLayout.size(ofValue: sockaddr_in())
}

fileprivate var sockaddr_in6_size : Int {
    return MemoryLayout.size(ofValue: sockaddr_in6())
}

extension GCDAsyncUdpSocket {
    
    func doSendTimeout() {
        assert(_currentSend != nil, "Invalid logic");
        guard let currentSend = _currentSend as? GCDAsyncUdpSendPacket else {
            assert(false)
            return
        }

        self.notify(didNotSendDataWithTag: currentSend.tag, dueToError: SocketError.TimeoutError("Send Timeout"))
        self.endCurrentSend()
        self.maybeDequeueSend()
    }

    func setupSendTimerWithTimeout(timeout: TimeInterval) {
        assert(self._sendTimer == nil, "Invalid logic")
        assert(timeout >= 0.0, "Invalid logic")
        
        self._sendTimer = DispatchSource.makeTimerSource(flags: .strict, queue: _socketQueue)
        self._sendTimer?.setEventHandler(handler: {
            self.doSendTimeout()
        })

        let tt = DispatchTime(uptimeNanoseconds: (UInt64)(timeout * TimeInterval(NSEC_PER_SEC)))
        _sendTimer?.schedule(deadline: tt, repeating: .infinity, leeway: .seconds(0))
        self._sendTimer!.resume()
    }
    
    func doSend() {
        assert(_currentSend != nil, "Invalid logic");
        guard let currentSend = _currentSend as? GCDAsyncUdpSendPacket else {
            assert(false)
            return
        }

        // Perform the actual send
        
        var result = 0
        let buffer = currentSend.buffer
        
        if (didConnect) {
            // Connected socket
            var socket = _socket4FD;
            if (currentSend.addressFamily == AF_INET6) {
                socket = _socket6FD
            }
            buffer.withUnsafeBytes({ (bytes) -> Void in
                result = Darwin.send(socket, bytes, buffer.count, 0)
            })
        } else {
            // Non-Connected socket
            var socket = _socket4FD
            let destAddress = currentSend.address!
            destAddress.withUnsafeBytes({ (ap:  UnsafePointer<sockaddr>) -> Void in
                buffer.withUnsafeBytes({ (bytes: UnsafePointer<Int8>) -> Void in
                    if (currentSend.addressFamily == AF_INET6) {
                        socket = _socket6FD
                    }
                    result = Darwin.sendto(socket, bytes, buffer.count, 0, ap, socklen_t(destAddress.count))
                })
            })
        }

        // If the socket wasn't bound before, it is now
        
        if (!didBind) {
            didBind = true
        }
        
        // Check the results.
        //
        // From the send() & sendto() manpage:
        //
        // Upon successful completion, the number of bytes which were sent is returned.
        // Otherwise, -1 is returned and the global variable errno is set to indicate the error.
        
        var waitingForSocket = false
        var socketError: Error? = nil
        
        if (result == 0) {
            waitingForSocket = true
        } else if (result < 0) {
            if (errno == EAGAIN) {
                waitingForSocket = true
            } else {
                let (host, _, _) = GCDAsyncUdpSocket.getHost(fromAddress: currentSend.address!)
                socketError = SocketError.SendError(GCDAsyncUdpSocket.errorMessageWithReason(reason: "Error in send(to: \(host)) function"))
            }
        }
        
        if (waitingForSocket) {
            // Not enough room in the underlying OS socket send buffer.
            // Wait for a notification of available space.
            print("warning: currentSend - waiting for socket")

            if (!isSock4CanAcceptBytes) {
                self.resumeSend4Source()
            }

            if (!isSock6CanAcceptBytes) {
                self.resumeSend6Source()
            }
            
            if self._sendTimer == nil && currentSend.timeout >= 0.0 {
                // Unable to send packet right away.
                // Start timer to timeout the send operation.
                self.setupSendTimerWithTimeout(timeout: currentSend.timeout)
            }
        } else if socketError != nil {
            self.closeWithError(error: socketError)
        } else {
            self.notify(didSendDataWithTag: currentSend.tag)
            self.endCurrentSend()
            self.maybeDequeueSend()
        }
    }

    /**
     * Asynchronously sends the given data, with the given timeout and tag.
     *
     * This method may only be used with a connected socket.
     * Recall that connecting is optional for a UDP socket.
     * For connected sockets, data can only be sent to the connected address.
     * For non-connected sockets, the remote destination is specified for each packet.
     * For more information about optionally connecting udp sockets, see the documentation for the connect methods above.
     *
     * @param data
     *     The data to send.
     *     If data is nil or zero-length, this method does nothing.
     *     If passing NSMutableData, please read the thread-safety notice below.
     *
     * @param timeout
     *    The timeout for the send opeartion.
     *    If the timeout value is negative, the send operation will not use a timeout.
     *
     * @param tag
     *    The tag is for your convenience.
     *    It is not sent or received over the socket in any manner what-so-ever.
     *    It is reported back as a parameter in the udpSocket:didSendDataWithTag:
     *    or udpSocket:didNotSendDataWithTag:dueToError: methods.
     *    You can use it as an array index, state id, type constant, etc.
     *
     *
     * Thread-Safety Note:
     * If the given data parameter is mutable (NSMutableData) then you MUST NOT alter the data while
     * the socket is sending it. In other words, it's not safe to alter the data until after the delegate method
     * udpSocket:didSendDataWithTag: or udpSocket:didNotSendDataWithTag:dueToError: is invoked signifying
     * that this particular send operation has completed.
     * This is due to the fact that GCDAsyncUdpSocket does NOT copy the data.
     * It simply retains it for performance reasons.
     * Often times, if NSMutableData is passed, it is because a request/response was built up in memory.
     * Copying this data adds an unwanted/unneeded overhead.
     * If you need to write data from an immutable buffer, and you need to alter the buffer before the socket
     * completes sending the bytes (which is NOT immediately after this method returns, but rather at a later time
     * when the delegate method notifies you), then you should first copy the bytes, and pass the copy to this method.
     **/
    open func send(_ data: Data, withTimeout timeout: TimeInterval, tag: Int) {
        
    }
    
    
    /**
     * Asynchronously sends the given data, with the given timeout and tag, to the given host and port.
     *
     * This method cannot be used with a connected socket.
     * Recall that connecting is optional for a UDP socket.
     * For connected sockets, data can only be sent to the connected address.
     * For non-connected sockets, the remote destination is specified for each packet.
     * For more information about optionally connecting udp sockets, see the documentation for the connect methods above.
     *
     * @param data
     *     The data to send.
     *     If data is nil or zero-length, this method does nothing.
     *     If passing NSMutableData, please read the thread-safety notice below.
     *
     * @param host
     *     The destination to send the udp packet to.
     *     May be specified as a domain name (e.g. "deusty.com") or an IP address string (e.g. "192.168.0.2").
     *     You may also use the convenience strings of "loopback" or "localhost".
     *
     * @param port
     *    The port of the host to send to.
     *
     * @param timeout
     *    The timeout for the send opeartion.
     *    If the timeout value is negative, the send operation will not use a timeout.
     *
     * @param tag
     *    The tag is for your convenience.
     *    It is not sent or received over the socket in any manner what-so-ever.
     *    It is reported back as a parameter in the udpSocket:didSendDataWithTag:
     *    or udpSocket:didNotSendDataWithTag:dueToError: methods.
     *    You can use it as an array index, state id, type constant, etc.
     *
     *
     * Thread-Safety Note:
     * If the given data parameter is mutable (NSMutableData) then you MUST NOT alter the data while
     * the socket is sending it. In other words, it's not safe to alter the data until after the delegate method
     * udpSocket:didSendDataWithTag: or udpSocket:didNotSendDataWithTag:dueToError: is invoked signifying
     * that this particular send operation has completed.
     * This is due to the fact that GCDAsyncUdpSocket does NOT copy the data.
     * It simply retains it for performance reasons.
     * Often times, if NSMutableData is passed, it is because a request/response was built up in memory.
     * Copying this data adds an unwanted/unneeded overhead.
     * If you need to write data from an immutable buffer, and you need to alter the buffer before the socket
     * completes sending the bytes (which is NOT immediately after this method returns, but rather at a later time
     * when the delegate method notifies you), then you should first copy the bytes, and pass the copy to this method.
     **/
    open func send(_ data: Data, toHost host: String, port: UInt16, withTimeout timeout: TimeInterval, tag: Int) {
        guard data.count > 0 else {
            return
        }
        let packet = GCDAsyncUdpSendPacket(data: data, timeout: timeout, tag: tag)
        packet.resolveInProgress = true
        
        self.asyncResolveHost(host: host, port: port) { (addresses,error) in
            packet.resolveInProgress = false
            if let tmp = addresses {
                packet.resolvedAddresses = tmp
            }
            packet.resolveError = error
            if let currentSend = self._currentSend as? GCDAsyncUdpSendPacket, packet === currentSend {
                try! self.doPreSend()
            }
            print(addresses ?? "null addresses", error ?? "no error")
        }
        
        _socketQueue.async {
            self._sendQueue.append(packet)
            self.maybeDequeueSend()
        }
        
    }
    
    
    /**
     * Asynchronously sends the given data, with the given timeout and tag, to the given address.
     *
     * This method cannot be used with a connected socket.
     * Recall that connecting is optional for a UDP socket.
     * For connected sockets, data can only be sent to the connected address.
     * For non-connected sockets, the remote destination is specified for each packet.
     * For more information about optionally connecting udp sockets, see the documentation for the connect methods above.
     *
     * @param data
     *     The data to send.
     *     If data is nil or zero-length, this method does nothing.
     *     If passing NSMutableData, please read the thread-safety notice below.
     *
     * @param remoteAddr
     *     The address to send the data to (specified as a sockaddr structure wrapped in a Data object).
     *
     * @param timeout
     *    The timeout for the send opeartion.
     *    If the timeout value is negative, the send operation will not use a timeout.
     *
     * @param tag
     *    The tag is for your convenience.
     *    It is not sent or received over the socket in any manner what-so-ever.
     *    It is reported back as a parameter in the udpSocket:didSendDataWithTag:
     *    or udpSocket:didNotSendDataWithTag:dueToError: methods.
     *    You can use it as an array index, state id, type constant, etc.
     *
     *
     * Thread-Safety Note:
     * If the given data parameter is mutable (NSMutableData) then you MUST NOT alter the data while
     * the socket is sending it. In other words, it's not safe to alter the data until after the delegate method
     * udpSocket:didSendDataWithTag: or udpSocket:didNotSendDataWithTag:dueToError: is invoked signifying
     * that this particular send operation has completed.
     * This is due to the fact that GCDAsyncUdpSocket does NOT copy the data.
     * It simply retains it for performance reasons.
     * Often times, if NSMutableData is passed, it is because a request/response was built up in memory.
     * Copying this data adds an unwanted/unneeded overhead.
     * If you need to write data from an immutable buffer, and you need to alter the buffer before the socket
     * completes sending the bytes (which is NOT immediately after this method returns, but rather at a later time
     * when the delegate method notifies you), then you should first copy the bytes, and pass the copy to this method.
     **/
    open func send(_ data: Data, toAddress remoteAddr: Data, withTimeout timeout: TimeInterval, tag: Int) {
        guard data.count > 0 else {
            return
        }
        let packet = GCDAsyncUdpSendPacket(data: data, timeout: timeout, tag: tag)
        packet.addressFamily = GCDAsyncUdpSocket.family(fromAddress: remoteAddr)
        packet.address = remoteAddr
        _socketQueue.async {
            self._sendQueue.append(packet)
            self.maybeDequeueSend()
        }
    }
    
    func createSockets() throws{
        if isIPv4Enabled {
            try self.createSocket4()
        }
        if isIPv6Enabled {
            try self.createSocket6()
        }
        
    }
    
    func getAddress(fromAddresses addresses: Array<Data>) throws -> (sa_family_t, Data?) {
        assert( self.isSocketQueue, "Must be dispatched on socketQueue")
        assert( !addresses.isEmpty, "Expected at least one address")
        var resultAF = AF_UNSPEC
        var resolvedIPv4Address = false
        var resolvedIPv6Address = false
        
        for data in addresses {
            switch Int32(GCDAsyncUdpSocket.family(fromAddress: data)) {
            case AF_INET:
                resolvedIPv4Address = true
            case AF_INET6:
                resolvedIPv6Address = true
            default:
                assert(false, "Addresses array contains invalid address")
            }
        }

        if (isIPv4Disabled && !resolvedIPv6Address) {
            let msg = "IPv4 has been disabled and DNS lookup found no IPv6 address(es)."
            throw GCDAsyncUdpSocketError.OtherError(msg)
        }
        
        if (isIPv6Disabled && !resolvedIPv4Address)
        {
            let msg = "IPv6 has been disabled and DNS lookup found no IPv4 address(es)."
            throw GCDAsyncUdpSocketError.OtherError(msg)
        }
        
        if (isIPv4Deactivated && !resolvedIPv6Address)
        {
            let msg = "IPv4 has been deactivated due to bind/connect, and DNS lookup found no IPv6 address(es)."
            throw GCDAsyncUdpSocketError.OtherError(msg)
        }
        
        if (isIPv6Deactivated && !resolvedIPv4Address)
        {
            let msg = "IPv6 has been deactivated due to bind/connect, and DNS lookup found no IPv4 address(es)."
            throw GCDAsyncUdpSocketError.OtherError(msg)
        }
        
        // Extract first IPv4 and IPv6 address in list
        
        var  ipv4WasFirstInList = true
        var address4: Data? = nil
        var address6: Data? = nil
        var resultAddress: Data? = nil
        
        for address in addresses {
            let af = GCDAsyncUdpSocket.family(fromAddress: address)

            if (af == AF_INET) {
                if (address4 == nil) {
                    address4 = address
                    if address6 != nil {
                        break
                    } else {
                        ipv4WasFirstInList = true
                    }
                }
            } else { // af == AF_INET6
                if (address6 == nil) {
                    address6 = address
                    if address4 != nil {
                        break
                    } else {
                        ipv4WasFirstInList = false
                    }
                }
            }
        }
        
        // Determine socket type
        
        let useIPv4 = ((isIPv4Preferred && address4 != nil) || (address6 == nil))
        let useIPv6 = ((isIPv4Preferred && address6 != nil) || (address4 == nil))
        
        assert(!(isIPv4Preferred && isIPv6Preferred), "Invalid config state")
        assert(!(useIPv4 && useIPv6), "Invalid logic")
        
        if (useIPv4 || (!useIPv6 && ipv4WasFirstInList)) {
            resultAF = AF_INET
            resultAddress = address4
        } else {
            resultAF = AF_INET6
            resultAddress = address6
        }
        
        return ( sa_family_t(resultAF), resultAddress)
    }
    
    func connect(withAddress4 address4: Data) throws -> Bool{
        assert( self.isSocketQueue, "Must be dispatched on socketQueue")
        let success = 0 == address4.withUnsafeBytes( { (addr:UnsafePointer<sockaddr>) -> Int32 in
            return Darwin.connect(socket4FD, addr, socklen_t(address4.count))
        })
        if !success {
            throw GCDAsyncUdpSocket.buildErrorWithReason(reason: "Error in connect() function")
        }
        self.closeSocket6()
        isIPv6Deactivated = true
        return success
    }
    
    func connect(withAddress6 address6: Data) throws -> Bool{
        assert( self.isSocketQueue, "Must be dispatched on socketQueue")
        let success = 0 == address6.withUnsafeBytes( { (addr:UnsafePointer<sockaddr>) -> Int32 in
            return Darwin.connect(socket6FD, addr, socklen_t(address6.count))
        })
        if !success {
            throw GCDAsyncUdpSocket.buildErrorWithReason(reason: "Error in connect() function")
        }
        self.closeSocket6()
        isIPv6Deactivated = true
        return success
    }
    
    func maybeConnect() {
        assert( self.isSocketQueue, "Must be dispatched on socketQueue")
        if let connectPacket  = _currentSend as?  GCDAsyncUdpSpecialPacket {
            if connectPacket.resolveInProgress {
                print("Waiting for DNS resolve...")
            } else {
                if let error = connectPacket.error {
                    self.notify(didNotConnect: error)
                } else {
                    var result = false
                    do {
                        let (af, address) = try getAddress(fromAddresses: connectPacket.addresses)
                        if let addr = address {
                            switch Int32(af) {
                            case AF_INET:
                                result = try connect(withAddress4: addr)
                            case AF_INET6:
                                result = try connect(withAddress6: addr)
                            default:
                                assert(false)
                            }
                            didBind = result
                            didConnect = result
                            _cachedConnectedAddress = address
                            
                            _cachedConnectedHost = GCDAsyncUdpSocket.host(fromAddress: addr)
                            _cachedConnectedPort = GCDAsyncUdpSocket.port(fromAddress: addr)
                            _cachedConnectedFamily = Int32(af)
                            
                            self.notify(didConnectToAddress: address!)
                        }
                    } catch let error {
                        notify(didNotConnect: error)
                    }
                }
                isConnecting = false
                self.endCurrentSend()
                self.maybeDequeueSend()
            }
        }
    }
    
    func doPreSend() throws {
        //
        // 1. Check for problems with send packet
        //

        var waitingForResolve = false
        var error: Error? = nil
        guard let currentSend = _currentSend as? GCDAsyncUdpSendPacket else {
            return
        }
        
        if didConnect {
            // Connected socket
            if (currentSend.resolveInProgress || !currentSend.resolvedAddresses.isEmpty || currentSend.resolveError != nil) {
                let msg = "Cannot specify destination of packet for connected socket"
                throw GCDAsyncUdpSocketError.BadConfigError(msg)
            } else {
                currentSend.address = _cachedConnectedAddress
                currentSend.addressFamily = sa_family_t(_cachedConnectedFamily) }
        } else {
            // Non-Connected socket
            if (currentSend.resolveInProgress) {
                // We're waiting for the packet's destination to be resolved.
                waitingForResolve = true
            } else if currentSend.resolveError != nil {
                error = currentSend.resolveError
            } else if currentSend.address == nil {
                if currentSend.resolvedAddresses.isEmpty {
                    let msg = "You must specify destination of packet for a non-connected socket"
                    throw GCDAsyncUdpSocketError.BadConfigError(msg)
                } else {
                    // Pick the proper address to use (out of possibly several resolved addresses)
                    
                    let (addressFamily, address) = try self.getAddress(fromAddresses: currentSend.resolvedAddresses)
                    
                    currentSend.address = address
                    currentSend.addressFamily = addressFamily
                }
            }
        }
        
        if (waitingForResolve) {
            // We're waiting for the packet's destination to be resolved.
            print("currentSend - waiting for address resolve")
            
            if isSock4CanAcceptBytes {
                self.suspendSend4Source()
            }
            if isSock6CanAcceptBytes {
                self.suspendSend6Source()
            }
            return
        }
        
        if error != nil {
            // Unable to send packet due to some error.
            // Notify delegate and move on.
            self.notify(didNotSendDataWithTag: currentSend.tag, dueToError: error)
            self.endCurrentSend()
            self.maybeDequeueSend()
            
            return
        }
        
        //
        // 2. Query sendFilter (if applicable)
        //
        
        if let block = _sendFilterBlock, let queue = _sendFilterQueue {
            // Query sendFilter
            if _sendFilterAsync {
                // Scenario 1 of 3 - Need to asynchronously query sendFilter
                
                currentSend.filterInProgress = true
                let sendPacket = currentSend
                queue.async {
                    let allowed = block(sendPacket.buffer, sendPacket.address!, sendPacket.tag)
                    self._socketQueue.async {
                        sendPacket.filterInProgress = false
                        if let tmp = self._currentSend as? GCDAsyncUdpSendPacket, sendPacket === tmp {
                            if (allowed) {
                                self.doSend()
                            } else {
                                print("currentSend - silently dropped by sendFilter")
                                self.notify(didSendDataWithTag: currentSend.tag)
                                self.endCurrentSend()
                                self.maybeDequeueSend()
                            }
                        }
                    }
                }
            } else {
                // Scenario 2 of 3 - Need to synchronously query sendFilter
                
                var allowed = true
                queue.async {
                    allowed = block(currentSend.buffer, currentSend.address!, currentSend.tag)
                }
                if (allowed) {
                    self.doSend()
                } else {
                    print("currentSend - silently dropped by sendFilter")
                    
                    self.notify(didSendDataWithTag: currentSend.tag)
                    self.endCurrentSend()
                    self.maybeDequeueSend()
                }
            }
            
        } else { // if (!sendFilterBlock || !sendFilterQueue)
            // Scenario 3 of 3 - No sendFilter. Just go straight into sending.
            self.doSend()
        }
    }


    func maybeDequeueSend() {
        assert( self.isSocketQueue, "Must be dispatched on socketQueue")
        if _currentSend == nil {
            if !didCreateSockets {
                do {
                    try createSockets()
                } catch let error {
                    closeWithError(error: error)
                }
            }
            while !_sendQueue.isEmpty {
                _currentSend = _sendQueue.removeFirst()
                if _currentSend is GCDAsyncUdpSpecialPacket {
                    self.maybeConnect()
                    return 
                } else if let currentSend = _currentSend as? GCDAsyncUdpSendPacket, let  error = currentSend.resolveError {
                    self.notify(didNotSendDataWithTag: currentSend.tag, dueToError: error)
                    _currentSend = nil
                    continue
                } else {
                    try! self.doPreSend()
                    break
                }
            }
            if _currentSend == nil && shouldCloseAfterSends {
                self.closeWithError(error: nil)
            }
        }
    }
}

