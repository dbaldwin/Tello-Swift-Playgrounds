//
//  GCDAsyncUdpSocket+CreateSockets.swift
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
    func createSocket4() throws {
        let socketFD = try GCDAsyncUdpSocket.createSocketByVersion(family: AF_INET)
        var status: Int32 = 0
        var maxSendSize: UInt = UInt(self._maxSendSize)
        status = setsockopt(socketFD, SOL_SOCKET, SO_SNDBUF, &maxSendSize, socklen_t(MemoryLayout.size(ofValue: maxSendSize)))
        if (status == -1){
            Darwin.close(socketFD);
            throw GCDAsyncUdpSocketError.CreateError(
                GCDAsyncUdpSocket.errorMessageWithReason(reason: "Error setting send buffer size (setsockopt)"))
        }
        var max4ReceiveSize: UInt = UInt(self._max4ReceiveSize)
        status = setsockopt(socketFD, SOL_SOCKET, SO_RCVBUF, &max4ReceiveSize, socklen_t(MemoryLayout.size(ofValue: max4ReceiveSize)))
        
        if (status == -1){
            Darwin.close(socketFD);
            throw GCDAsyncUdpSocketError.CreateError(GCDAsyncUdpSocket.errorMessageWithReason(reason: "Error setting receive buffer size (setsockopt)"))
        }
        
        self._socket4FD = socketFD
    }

    func createSocket6() throws {
        let socket6FD = try GCDAsyncUdpSocket.createSocketByVersion(family: AF_INET6)
        /**
         * The theoretical maximum size of any IPv4 UDP packet is UINT16_MAX = 65535.
         * The theoretical maximum size of any IPv6 UDP packet is UINT32_MAX = 4294967295.
         *
         * The default maximum size of the UDP buffer in iOS is 9216 bytes.
         *
         * This is the reason of #222(GCD does not necessarily return the size of an entire UDP packet) and
         *  #535(GCDAsyncUDPSocket can not send data when data is greater than 9K)
         *
         *
         * Enlarge the maximum size of UDP packet.
         * I can not ensure the protocol type now so that the max size is set to 65535 :)
         **/
        var maxSendSize: UInt = UInt(self._maxSendSize)
        var status = setsockopt(socket6FD, SOL_SOCKET, SO_SNDBUF, &maxSendSize, socklen_t(MemoryLayout.size(ofValue: maxSendSize)))
        if (status == -1){
            Darwin.close(socket6FD);
            throw GCDAsyncUdpSocketError.CreateError(GCDAsyncUdpSocket.errorMessageWithReason(reason: "Error enabling address reuse (setsockopt)"))
        }
        var max6ReceiveSize: UInt = UInt(self._max6ReceiveSize)
        status = setsockopt(socket6FD, SOL_SOCKET, SO_RCVBUF, &max6ReceiveSize, socklen_t(MemoryLayout.size(ofValue: max6ReceiveSize)))
        
        if (status == -1){
            Darwin.close(socket6FD);
            throw GCDAsyncUdpSocketError.CreateError(GCDAsyncUdpSocket.errorMessageWithReason(reason: "Error enabling address reuse (setsockopt)"))
        }
        
        self._socket6FD = socket6FD
    }

}

