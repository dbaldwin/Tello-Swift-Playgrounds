//
//  GCDAsyncUdpSocket+Delegates.swift
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
public protocol GCDAsyncUdpSocketDelegate {
    
    
    /**
     * By design, UDP is a connectionless protocol, and connecting is not needed.
     * However, you may optionally choose to connect to a particular host for reasons
     * outlined in the documentation for the various connect methods listed above.
     *
     * This method is called if one of the connect methods are invoked, and the connection is successful.
     **/
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data)
    
    
    /**
     * By design, UDP is a connectionless protocol, and connecting is not needed.
     * However, you may optionally choose to connect to a particular host for reasons
     * outlined in the documentation for the various connect methods listed above.
     *
     * This method is called if one of the connect methods are invoked, and the connection fails.
     * This may happen, for example, if a domain name is given for the host and the domain name is unable to be resolved.
     **/
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?)
    
    
    /**
     * Called when the datagram with the given tag has been sent.
     **/
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int)
    
    
    /**
     * Called if an error occurs while trying to send a datagram.
     * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
     **/
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?)
    
    
    /**
     * Called when the socket has received the requested datagram.
     **/
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?)
    
    
    /**
     * Called when the socket is closed.
     **/
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?)
}

/**
 * You may optionally set a receive filter for the socket.
 * A filter can provide several useful features:
 *
 * 1. Many times udp packets need to be parsed.
 *    Since the filter can run in its own independent queue, you can parallelize this parsing quite easily.
 *    The end result is a parallel socket io, datagram parsing, and packet processing.
 *
 * 2. Many times udp packets are discarded because they are duplicate/unneeded/unsolicited.
 *    The filter can prevent such packets from arriving at the delegate.
 *    And because the filter can run in its own independent queue, this doesn't slow down the delegate.
 *
 *    - Since the udp protocol does not guarantee delivery, udp packets may be lost.
 *      Many protocols built atop udp thus provide various resend/re-request algorithms.
 *      This sometimes results in duplicate packets arriving.
 *      A filter may allow you to architect the duplicate detection code to run in parallel to normal processing.
 *
 *    - Since the udp socket may be connectionless, its possible for unsolicited packets to arrive.
 *      Such packets need to be ignored.
 *
 * 3. Sometimes traffic shapers are needed to simulate real world environments.
 *    A filter allows you to write custom code to simulate such environments.
 *    The ability to code this yourself is especially helpful when your simulated environment
 *    is more complicated than simple traffic shaping (e.g. simulating a cone port restricted router),
 *    or the system tools to handle this aren't available (e.g. on a mobile device).
 *
 * @param data    - The packet that was received.
 * @param address - The address the data was received from.
 *                  See utilities section for methods to extract info from address.
 * @param context - Out parameter you may optionally set, which will then be passed to the delegate method.
 *                  For example, filter block can parse the data and then,
 *                  pass the parsed data to the delegate.
 *
 * @returns - YES if the received packet should be passed onto the delegate.
 *            NO if the received packet should be discarded, and not reported to the delegete.
 *
 * Example:
 *
 * GCDAsyncUdpSocketReceiveFilterBlock filter = ^Bool (Data *data, Data *address, id *context) {
 *
 *     MyProtocolMessage *msg = [MyProtocol parseMessage:data];
 *
 *     *context = response;
 *     return (response != nil);
 * };
 * [udpSocket setReceiveFilter:filter withQueue:myParsingQueue];
 *
 **/
public typealias GCDAsyncUdpSocketReceiveFilterBlock = (Data, Data, AnyObject?) -> Bool

/**
 * You may optionally set a send filter for the socket.
 * A filter can provide several interesting possibilities:
 *
 * 1. Optional caching of resolved addresses for domain names.
 *    The cache could later be consulted, resulting in fewer system calls to getaddrinfo.
 *
 * 2. Reusable modules of code for bandwidth monitoring.
 *
 * 3. Sometimes traffic shapers are needed to simulate real world environments.
 *    A filter allows you to write custom code to simulate such environments.
 *    The ability to code this yourself is especially helpful when your simulated environment
 *    is more complicated than simple traffic shaping (e.g. simulating a cone port restricted router),
 *    or the system tools to handle this aren't available (e.g. on a mobile device).
 *
 * @param data    - The packet that was received.
 * @param address - The address the data was received from.
 *                  See utilities section for methods to extract info from address.
 * @param tag     - The tag that was passed in the send method.
 *
 * @returns - YES if the packet should actually be sent over the socket.
 *            NO if the packet should be silently dropped (not sent over the socket).
 *
 * Regardless of the return value, the delegate will be informed that the packet was successfully sent.
 *
 **/
public typealias GCDAsyncUdpSocketSendFilterBlock = (Data, Data, Int) -> Bool
