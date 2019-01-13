//
//  GCDAsyncUdpSocket+ReceivingSockets.swift
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
    
    func guardReceive() -> Bool {
        if !self.isReceiveOnce && !self.isReceiveContinuous {
            if _socket4FDBytesAvailable > 0 {
                self.suspendReceive4Source()
            }
            
            if _socket6FDBytesAvailable > 0 {
                self.suspendReceive6Source()
            }
            return false
        }
        
        if self.isReceiveOnce && _pendingFilterOperations > 0 {
            // Suspend receving before filter operations are all done
            if _socket4FDBytesAvailable > 0 {
                self.suspendReceive4Source()
            }
            
            if _socket6FDBytesAvailable > 0 {
                self.suspendReceive6Source()
            }
            return false
        }
        
        if (_socket4FDBytesAvailable == 0) && (_socket6FDBytesAvailable == 0) {
            self.resumeReceive4Source()
            self.resumeReceive6Source()
            return false
        }
        return true
    }
    
    func shouldReceiveDataFromIPv4() -> Bool {
        var doReceive4: Bool = false
        if isConnected { // isConnected is true only when in client mode
            doReceive4 = _socket4FD != InvalidSocket
        } else {
            if _socket4FDBytesAvailable > 0 {
                if _socket6FDBytesAvailable > 0 {
                    doReceive4 = self.isFlipFlop
                    self.toggoleFlipFlop()
                } else {
                    doReceive4 = true
                }
            } else {
                doReceive4 = false
            }
        }
        return doReceive4
    }
    
    func receiveData(socketFD: Int32, buf: UnsafeMutableRawPointer, sockaddr: UnsafeMutablePointer<sockaddr>, sockaddr_len: UnsafeMutablePointer<socklen_t>) {
    }
    
    func doReceive() {
        guard guardReceive() else {
            return
        }

        var result: Int = 0

        var data: Data? = nil
        var addr4: Data? = nil
        var addr6: Data? = nil
        var doReceive4 = self.shouldReceiveDataFromIPv4()
        if doReceive4 {
            assert(self._socket4FDBytesAvailable > 0, "Invalid logic")
            
            var in4 = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
            defer {
                in4.deallocate()
            }
            var sockaddr4len = socklen_t(GCDAsyncUdpSocket.sockaddr_in_size)
            
            // #222: GCD does not necessarily return the size of an entire UDP packet
            // from dispatch_source_get_data(), so we must use the maximum packet size.
            let bufSize = Int(self._max4ReceiveSize)
            let alignedTo = MemoryLayout.size(ofValue: Int())
            let buf = UnsafeMutableRawPointer.allocate(byteCount: bufSize, alignment: alignedTo)
            in4.withMemoryRebound(to: sockaddr.self, capacity: 1, { (pointer) in
                result = recvfrom(socket4FD, buf, bufSize, 0, pointer, &sockaddr4len)
            })
            
            if (result > 0) {
                if result >= self._socket4FDBytesAvailable {
                    self._socket4FDBytesAvailable = 0
                } else {
                    self._socket4FDBytesAvailable -=  UInt(result)
                }
                
                data = Data(bytesNoCopy: buf, count: result, deallocator: .custom({ (pointer, bufSize) in
                    pointer.deallocate()
                }))
                
                addr4 = Data(bytes: in4, count: GCDAsyncUdpSocket.sockaddr_in_size)
            } else {
                print(String(format: "recvfrom(socket4FD) = %d", errno))
                self._socket4FDBytesAvailable = 0
                buf.deallocate()
            }
        } else { // IPv6
            assert(self._socket6FDBytesAvailable > 0, "Invalid logic")
            
            let in6 = UnsafeMutablePointer<sockaddr_in6>.allocate(capacity: 1)
            defer {
                in6.deallocate()
            }
            var sockaddr6len = socklen_t(GCDAsyncUdpSocket.sockaddr_in6_size)
            
            // #222: GCD does not necessarily return the size of an entire UDP packet
            // from dispatch_source_get_data(), so we must use the maximum packet size.
            let bufSize = Int(self._max6ReceiveSize)
            let alignedTo = MemoryLayout.size(ofValue: Int())
            let buf = UnsafeMutableRawPointer.allocate(byteCount: bufSize, alignment: alignedTo)
            
            in6.withMemoryRebound(to: sockaddr.self, capacity: 1, { (pointer) in
                result = recvfrom(socket6FD, buf, bufSize, 0, pointer, &sockaddr6len)
            })
            
            if (result > 0) {
                if result >= self._socket6FDBytesAvailable {
                    self._socket6FDBytesAvailable = 0
                } else {
                    self._socket6FDBytesAvailable -=  UInt(result)
                }
                
                data = Data(bytesNoCopy: buf, count: result, deallocator: .custom({ (pointer, bufSize) in
                    pointer.deallocate()
                }))
                
                addr6 = Data(bytes: in6, count: GCDAsyncUdpSocket.sockaddr_in6_size)
            } else {
                print(String(format: "recvfrom(socket6FD) = %d", errno))
                self._socket6FDBytesAvailable = 0
                buf.deallocate()
            }
        }
        
        var waitingForSocket: Bool = false
        var notifiedDelegate: Bool = false
        var skipped: Bool = false
        
        var socketError: Error? = nil
        if (result == 0) {
            waitingForSocket = true;
        }  else if (result < 0) {
            if (errno == EAGAIN) {
                waitingForSocket = true
            } else {
                socketError = GCDAsyncUdpSocket.buildErrorWithReason(reason: "Error in recvfrom() function")
            }
        } else {
            if isConnected { // Client mode
                skipped = !self.isConnectedToAddress4(someAddr: addr4) ||
                    !self.isConnectedToAddress6(someAddr: addr6)
            }
            
            let addr = (addr4 != nil) ? addr4 : addr6;
            if  !skipped {
                if let receiveFilterBlock = self._receiveFilterBlock, let queue = self._receiveFilterQueue, let receivedData = data, let fromAddress = addr {
                    var accepted = false
                    // Run data through filter, and if approved, notify delegate
                    if self._receiveFilterAsync {
                        self._pendingFilterOperations += 1
                        
                        queue.async {
                            accepted = receiveFilterBlock(receivedData, fromAddress, nil)
                            // Transition back to socketQueue to get the current delegate / delegateQueue
                            self._socketQueue.async {
                                self._pendingFilterOperations -= 1
                                if (accepted) {
                                    self.notify(didReceiveData: receivedData, fromAddress: fromAddress, withFilterContext: nil)
                                } else {
                                    print("received packet silently dropped by receiveFilter")
                                }
                                
                                if self.isReceiveOnce {
                                    if (accepted) {
                                        // The delegate has been notified,
                                        // so our receive once operation has completed.
                                        self.isReceiveOnce = false
                                    } else if (self._pendingFilterOperations == 0) {
                                        // All pending filter operations have completed,
                                        // and none were allowed through.
                                        // Our receive once operation hasn't completed yet.
                                        self.doReceive()
                                    }
                                }
                            }
                        }
                    } else { // if (!_receiveFilterAsync)
                        queue.sync {
                            accepted = receiveFilterBlock(receivedData, fromAddress, nil);
                        }
                        
                        if (accepted) {
                            self.notify(didReceiveData: receivedData, fromAddress: fromAddress, withFilterContext: nil)
                            notifiedDelegate = true
                        } else {
                            print("received packet silently dropped by receiveFilter")
                            skipped = true
                        }
                    }
                } else if let receivedData = data, let fromAddress = addr { // if (!receiveFilterBlock || !receiveFilterQueue)
                    self.notify(didReceiveData: receivedData, fromAddress: fromAddress, withFilterContext: nil)
                    notifiedDelegate = true
                }
            }
        }
        
        if (waitingForSocket) {
            // Wait for a notification of available data.
            
            if self._socket4FDBytesAvailable == 0 {
                self.resumeReceive4Source()
            }
            if self._socket6FDBytesAvailable == 0 {
                self.resumeReceive6Source()
            }
        } else if socketError != nil {
            self.closeWithError(error: socketError)
        } else {
            if self.isReceiveContinuous {
                // Continuous receive mode
                self.doReceive()
            } else {
                // One-at-a-time receive mode
                if (notifiedDelegate) {
                    // The delegate has been notified (no set filter).
                    // So our receive once operation has completed.
                    self.isReceiveOnce = false
                } else if (skipped) {
                    self.doReceive()
                } else {
                    // Waiting on asynchronous receive filter...
                }
            }
        }
    }
    
    func doReceiveEOF() {
        let error = GCDAsyncUdpSocketError.ClosedError("Socket closed")
        self.closeWithError(error: error)
    }
    
    
    /**
     * There are two modes of operation for receiving packets: one-at-a-time & continuous.
     *
     * In one-at-a-time mode, you call receiveOnce everytime your delegate is ready to process an incoming udp packet.
     * Receiving packets one-at-a-time may be better suited for implementing certain state machine code,
     * where your state machine may not always be ready to process incoming packets.
     *
     * In continuous mode, the delegate is invoked immediately everytime incoming udp packets are received.
     * Receiving packets continuously is better suited to real-time streaming applications.
     *
     * You may switch back and forth between one-at-a-time mode and continuous mode.
     * If the socket is currently in continuous mode, calling this method will switch it to one-at-a-time mode.
     *
     * When a packet is received (and not filtered by the optional receive filter),
     * the delegate method (udpSocket:didReceiveData:fromAddress:withFilterContext:) is invoked.
     *
     * If the socket is able to begin receiving packets, this method returns YES.
     * Otherwise it returns NO, and sets the errPtr with appropriate error information.
     *
     * An example error:
     * You created a udp socket to act as a server, and immediately called receive.
     * You forgot to first bind the socket to a port number, and received a error with a message like:
     * "Must bind socket before you can receive data."
     **/
    open func receiveOnce() throws {
        let block = {
            if !self.isReceiveOnce {
                if !self.didCreateSockets {
                    throw GCDAsyncUdpSocketError.BadConfigError("Must bind socket before you can receive data. You can do this explicitly via bind, or implicitly via connect or by sending data.")
                }
                self.isReceiveContinuous = false
                self.isReceiveOnce = true
                
                self._socketQueue.async(execute: {
                    self.doReceive()
                })
            }
        }
        try runSyncWithoutReturnValue(block: block)
    }
    
    /**
     * There are two modes of operation for receiving packets: one-at-a-time & continuous.
     *
     * In one-at-a-time mode, you call receiveOnce everytime your delegate is ready to process an incoming udp packet.
     * Receiving packets one-at-a-time may be better suited for implementing certain state machine code,
     * where your state machine may not always be ready to process incoming packets.
     *
     * In continuous mode, the delegate is invoked immediately everytime incoming udp packets are received.
     * Receiving packets continuously is better suited to real-time streaming applications.
     *
     * You may switch back and forth between one-at-a-time mode and continuous mode.
     * If the socket is currently in one-at-a-time mode, calling this method will switch it to continuous mode.
     *
     * For every received packet (not filtered by the optional receive filter),
     * the delegate method (udpSocket:didReceiveData:fromAddress:withFilterContext:) is invoked.
     *
     * If the socket is able to begin receiving packets, this method returns YES.
     * Otherwise it returns NO, and sets the errPtr with appropriate error information.
     *
     * An example error:
     * You created a udp socket to act as a server, and immediately called receive.
     * You forgot to first bind the socket to a port number, and received a error with a message like:
     * "Must bind socket before you can receive data."
     **/
    open func beginReceiving() throws {
        let block = {
            if !self.isReceiveContinuous {
                if !self.didCreateSockets {
                    throw GCDAsyncUdpSocketError.BadConfigError("Must bind socket before you can receive data. You can do this explicitly via bind, or implicitly via connect or by sending data.")
                }
                self.isReceiveContinuous = true
                self.isReceiveOnce = false

                self._socketQueue.async(execute: {
                    self.doReceive()
                })
            }
        }
        try runSyncWithoutReturnValue(block: block)
    }
    
    /**
     * If the socket is currently receiving (beginReceiving has been called), this method pauses the receiving.
     * That is, it won't read any more packets from the underlying OS socket until beginReceiving is called again.
     *
     * Important Note:
     * GCDAsyncUdpSocket may be running in parallel with your code.
     * That is, your delegate is likely running on a separate thread/dispatch_queue.
     * When you invoke this method, GCDAsyncUdpSocket may have already dispatched delegate methods to be invoked.
     * Thus, if those delegate methods have already been dispatch_async'd,
     * your didReceive delegate method may still be invoked after this method has been called.
     * You should be aware of this, and program defensively.
     **/
    open func pauseReceiving() {
        runBlockAsyncSafely {
            self.isReceiveContinuous = false
            self.isReceiveOnce = false
            
            if self._socket4FDBytesAvailable > 0 {
                self.suspendReceive4Source()
            }
            if self._socket6FDBytesAvailable > 0 {
                self.suspendReceive6Source()
            }
        }
    }

}

