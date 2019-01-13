//
//  GCDAsyncUdpSocket+DispatchSource.swift
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


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
extension GCDAsyncUdpSocket {
    func setupSendAndReceiveSourcesForSocket4() {
        assert( self.isSocketQueue, "Must be dispatched on socketQueue")
        self._send4Source = DispatchSource.makeWriteSource(fileDescriptor: self._socket4FD, queue: _socketQueue!)
        self._receive4Source = DispatchSource.makeReadSource(fileDescriptor: self._socket4FD, queue: _socketQueue!)
        
        // Setup event handlers
        self._send4Source?.setEventHandler(handler: {
            self.isSock4CanAcceptBytes = true
            if self._currentSend == nil {
                print("Nothing to send");
                self.suspendSend4Source()
            } else if let currentSend =  self._currentSend as? GCDAsyncUdpSpecialPacket, currentSend.resolveInProgress {
                print("currentSend - waiting for address resolve");
                self.suspendSend4Source()
            } else if let currentSend = self._currentSend as? GCDAsyncUdpSendPacket, currentSend.filterInProgress {
                print("currentSend - waiting on sendFilter")
                self.suspendSend4Source()
            } else {
                self.doSend()
            }
        })
        
        self._receive4Source?.setEventHandler(handler: {
            self._socket4FDBytesAvailable = self._receive4Source!.data
            // print(String(format: "socket4FDBytesAvailable: %lu\n", self._socket4FDBytesAvailable))
            if self._socket4FDBytesAvailable > 0 {
                self.doReceive()
            } else {
                self.doReceiveEOF()
            }
        })
        
        var socketFDRefCount = 2
        let socketFD = self._socket4FD
        self._send4Source?.setCancelHandler(handler: {
            print("send4CancelBlock")
            socketFDRefCount -= 1
            if socketFDRefCount == 0 {
                Darwin.close(socketFD)
            }
        })
        
        self._receive4Source?.setCancelHandler(handler: {
            print("receive4CancelBlock")
            socketFDRefCount -= 1
            if socketFDRefCount == 0 {
                Darwin.close(socketFD)
            }
        })
        
        self._socket4FDBytesAvailable = 0;
        
        self.isSock4CanAcceptBytes = true
        self.isSend4SourceSuspended = true
        self.isReceive4SourceSuspended = true
    }
    
    func setupSendAndReceiveSourcesForSocket6() {
        assert( self.isSocketQueue, "Must be dispatched on socketQueue")
        self._send6Source = DispatchSource.makeWriteSource(fileDescriptor: self._socket6FD, queue: _socketQueue!)
        self._receive6Source = DispatchSource.makeReadSource(fileDescriptor: self._socket6FD, queue: _socketQueue!)
        
        self._send6Source?.setEventHandler(handler: {
            self._flags |= GCDAsyncUdpSocketFlags.kSock6CanAcceptBytes
            if self._currentSend == nil {
                print("Nothing to send");
                self.suspendSend6Source()
            } else if let currentSend =  self._currentSend as? GCDAsyncUdpSpecialPacket, currentSend.resolveInProgress {
                print("currentSend - waiting for address resolve");
                self.suspendSend6Source()
            } else if let currentSend = self._currentSend as? GCDAsyncUdpSendPacket, currentSend.filterInProgress {
                print("currentSend - waiting on sendFilter")
                self.suspendSend6Source()
            } else {
                self.doSend()
            }
        })
        
        self._receive6Source?.setEventHandler(handler: {
            self._socket6FDBytesAvailable = self._receive6Source!.data
            print(String(format: "socket6FDBytesAvailable: %lu\n", self._socket6FDBytesAvailable))
            if self._socket6FDBytesAvailable > 0 {
                self.doReceive()
            } else {
                self.doReceiveEOF()
            }
        })
        
        var socketFDRefCount = 2
        let socketFD = self._socket6FD
        self._send6Source?.setCancelHandler(handler: {
            print("send6CancelBlock")
            socketFDRefCount -= 1
            if socketFDRefCount == 0 {
                Darwin.close(socketFD)
            }
        })
        
        self._receive6Source?.setCancelHandler(handler: {
            print("receive6CancelBlock")
            socketFDRefCount -= 1
            if socketFDRefCount == 0 {
                Darwin.close(socketFD)
            }
        })
        
        self._socket6FDBytesAvailable = 0;
        
        self.isSock6CanAcceptBytes = true
        self.isSend6SourceSuspended = true
        self.isReceive6SourceSuspended = true
    }
    

    func suspendSend4Source() {
        if let source = self._send4Source, !self.isSend4SourceSuspended {
            source.suspend()
            self.isSend4SourceSuspended = true
        }
    }
    
    func suspendSend6Source() {
        if let source = self._send6Source, !self.isSend6SourceSuspended {
            source.suspend()
            self.isSend6SourceSuspended = true
        }
    }

    func resumeSend4Source() {
        if let source = self._send4Source, self.isSend4SourceSuspended {
            source.resume()
            self.isSend4SourceSuspended = false
        }
    }
    
    func resumeSend6Source() {
        if let source = self._send6Source, self.isSend6SourceSuspended {
            source.resume()
            self.isSend6SourceSuspended = false
        }
    }
    
    func suspendReceive4Source() {
        if let source = self._receive4Source, !self.isReceive4SourceSuspended {
            source.suspend()
            self.isReceive4SourceSuspended = true
        }
    }
    
    func suspendReceive6Source() {
        if let source = self._receive6Source, !self.isReceive6SourceSuspended {
            source.suspend()
            self.isReceive6SourceSuspended = true
        }
    }
    
    
    func resumeReceive4Source() {
        if let source = self._receive4Source, self.isReceive4SourceSuspended {
            source.resume()
            self.isReceive4SourceSuspended = false
        }
    }
    
    func resumeReceive6Source() {
        if let source = self._receive6Source, self.isReceive6SourceSuspended {
            source.resume()
            self.isReceive6SourceSuspended = false
        }
    }
}

