//
//  GCDAsyncUdpSocket+Filters.swift
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
     * For more information about GCDAsyncUdpSocketSendFilterBlock, see the documentation for its typedef.
     * To remove a previously set filter, invoke this method and pass a nil filterBlock and NULL filterQueue.
     *
     * Note: This method invokes setSendFilter:withQueue:isAsynchronous: (documented below),
     *       passing YES for the isAsynchronous parameter.
     **/
    open func setSendFilter(_ filterBlock: GCDAsyncUdpSocketSendFilterBlock?, with filterQueue: DispatchQueue?) {
        
    }
    
    
    /**
     * The receive filter can be run via dispatch_async or dispatch_sync.
     * Most typical situations call for asynchronous operation.
     *
     * However, there are a few situations in which synchronous operation is preferred.
     * Such is the case when the filter is extremely minimal and fast.
     * This is because dispatch_sync is faster than dispatch_async.
     *
     * If you choose synchronous operation, be aware of possible deadlock conditions.
     * Since the socket queue is executing your block via dispatch_sync,
     * then you cannot perform any tasks which may invoke dispatch_sync on the socket queue.
     * For example, you can't query properties on the socket.
     **/
    open func setSendFilter(_ filterBlock: GCDAsyncUdpSocketSendFilterBlock?,
                            with filterQueue: DispatchQueue?, isAsynchronous: Bool) {
        
    }
    
    
    
    
    /**
     * You may optionally set a receive filter for the socket.
     * This receive filter may be set to run in its own queue (independent of delegate queue).
     *
     * A filter can provide several useful features.
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
     * For more information about GCDAsyncUdpSocketReceiveFilterBlock, see the documentation for its typedef.
     * To remove a previously set filter, invoke this method and pass a nil filterBlock and NULL filterQueue.
     *
     * Note: This method invokes setReceiveFilter:withQueue:isAsynchronous: (documented below),
     *       passing YES for the isAsynchronous parameter.
     **/
    open func setReceiveFilter(_ filterBlock: GCDAsyncUdpSocketReceiveFilterBlock?, with filterQueue: DispatchQueue?) {
        
    }
    
    
    /**
     * The receive filter can be run via dispatch_async or dispatch_sync.
     * Most typical situations call for asynchronous operation.
     *
     * However, there are a few situations in which synchronous operation is preferred.
     * Such is the case when the filter is extremely minimal and fast.
     * This is because dispatch_sync is faster than dispatch_async.
     *
     * If you choose synchronous operation, be aware of possible deadlock conditions.
     * Since the socket queue is executing your block via dispatch_sync,
     * then you cannot perform any tasks which may invoke dispatch_sync on the socket queue.
     * For example, you can't query properties on the socket.
     **/
    open func setReceiveFilter(_ filterBlock: GCDAsyncUdpSocketReceiveFilterBlock?, with filterQueue: DispatchQueue?, isAsynchronous: Bool) {
        
    }

}

