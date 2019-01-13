//
//  GCDAsyncUdpSocket+ConnectingSockets.swift
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

    /**
     * Connects the UDP socket to the given host and port.
     * By design, UDP is a connectionless protocol, and connecting is not needed.
     *
     * Choosing to connect to a specific host/port has the following effect:
     * - You will only be able to send data to the connected host/port.
     * - You will only be able to receive data from the connected host/port.
     * - You will receive ICMP messages that come from the connected host/port, such as "connection refused".
     *
     * The actual process of connecting a UDP socket does not result in any communication on the socket.
     * It simply changes the internal state of the socket.
     *
     * You cannot bind a socket after it has been connected.
     * You can only connect a socket once.
     *
     * The host may be a domain name (e.g. "deusty.com") or an IP address string (e.g. "192.168.0.2").
     *
     * This method is asynchronous as it requires a DNS lookup to resolve the given host name.
     * If an obvious error is detected, this method immediately returns NO and sets errPtr.
     * If you don't care about the error, you can pass nil for errPtr.
     * Otherwise, this method returns YES and begins the asynchronous connection process.
     * The result of the asynchronous connection process will be reported via the delegate methods.
     **/
    open func connect(toHost host: String, onPort port: UInt16) throws {
        
    }
    
    
    /**
     * Connects the UDP socket to the given address, specified as a sockaddr structure wrapped in a Data object.
     *
     * If you have an existing struct sockaddr you can convert it to a Data object like so:
     * struct sockaddr sa  -> Data *dsa = [Data dataWithBytes:&remoteAddr length:remoteAddr.sa_len];
     * struct sockaddr *sa -> Data *dsa = [Data dataWithBytes:remoteAddr length:remoteAddr->sa_len];
     *
     * By design, UDP is a connectionless protocol, and connecting is not needed.
     *
     * Choosing to connect to a specific address has the following effect:
     * - You will only be able to send data to the connected address.
     * - You will only be able to receive data from the connected address.
     * - You will receive ICMP messages that come from the connected address, such as "connection refused".
     *
     * Connecting a UDP socket does not result in any communication on the socket.
     * It simply changes the internal state of the socket.
     *
     * You cannot bind a socket after its been connected.
     * You can only connect a socket once.
     *
     * On success, returns YES.
     * Otherwise returns NO, and sets errPtr. If you don't care about the error, you can pass nil for errPtr.
     *
     * Note: Unlike the connectToHost:onPort:error: method, this method does not require a DNS lookup.
     * Thus when this method returns, the connection has either failed or fully completed.
     * In other words, this method is synchronous, unlike the asynchronous connectToHost::: method.
     * However, for compatibility and simplification of delegate code, if this method returns YES
     * then the corresponding delegate method (udpSocket:didConnectToHost:port:) is still invoked.
     **/
    open func connect(toAddress remoteAddr: Data) throws {
        
    }


}

