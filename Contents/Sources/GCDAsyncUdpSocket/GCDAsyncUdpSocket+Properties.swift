//
//  GCDAsyncUdpSocket+Properties.swift
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

    var isSocketQueue: Bool {
         return DispatchQueue.getSpecific(key: _IsOnSocketQueueOrTargetQueueKey) != nil
    }

    open var delegate: GCDAsyncUdpSocketDelegate? {
        get {
            return runSyncWithReturnValue(block: { () -> Any? in
                return self._delegate
            }) as? GCDAsyncUdpSocketDelegate
        }
        set{
            setDelegate(newValue, sync: false)
        }
    }
    
    open func setDelegate(_ delegate: GCDAsyncUdpSocketDelegate?, sync: Bool) {
        let block = {
            self._delegate = delegate
        }
        
        if isSocketQueue {
            block()
        } else {
            if sync {
                _socketQueue.sync(execute: block)
            } else {
                _socketQueue.async(execute: block)
            }
        }
    }

    open var delegateQueue: DispatchQueue? {
        get{
            return runSyncWithReturnValue(block: { () -> Any? in
                return self._delegateQueue
            }) as? DispatchQueue
        }
        set {
            runBlockAsyncSafely {
                self._delegateQueue = newValue
            }
        }
    }


    /**
     * By default, both IPv4 and IPv6 are enabled.
     *
     * This means GCDAsyncUdpSocket automatically supports both protocols,
     * and can send to IPv4 or IPv6 addresses,
     * as well as receive over IPv4 and IPv6.
     *
     * For operations that require DNS resolution, GCDAsyncUdpSocket supports both IPv4 and IPv6.
     * If a DNS lookup returns only IPv4 results, GCDAsyncUdpSocket will automatically use IPv4.
     * If a DNS lookup returns only IPv6 results, GCDAsyncUdpSocket will automatically use IPv6.
     * If a DNS lookup returns both IPv4 and IPv6 results, then the protocol used depends on the configured preference.
     * If IPv4 is preferred, then IPv4 is used.
     * If IPv6 is preferred, then IPv6 is used.
     * If neutral, then the first IP version in the resolved array will be used.
     *
     * Starting with Mac OS X 10.7 Lion and iOS 5, the default IP preference is neutral.
     * On prior systems the default IP preference is IPv4.
     **/
    open var isIPv4Enabled: Bool {
        get {
            return runSyncWithReturnValue(block: { () -> Any in
                return ((self._config & GCDAsyncUdpSocketConfig.kIPv4Disabled ) == 0)
            }) as! Bool
        }
        set {
            runBlockAsyncSafely {
                if newValue {
                    self._config &= ~GCDAsyncUdpSocketConfig.kIPv4Disabled
                } else {
                    self._config |= GCDAsyncUdpSocketConfig.kIPv4Disabled
                }
            }
        }
    }

    open var isIPv6Enabled: Bool {
        get {
            return runSyncWithReturnValue(block: { () -> Any in
                return ((self._config & GCDAsyncUdpSocketConfig.kIPv6Disabled ) == 0)
            }) as! Bool
        }
        set {
            runBlockAsyncSafely {
                if newValue {
                    self._config &= ~GCDAsyncUdpSocketConfig.kIPv6Disabled
                } else {
                    self._config |= GCDAsyncUdpSocketConfig.kIPv6Disabled
                }
            }
        }
    }

    open var isIPv4Preferred: Bool {
        get {
            return runSyncWithReturnValue(block: { () -> Any in
                return ((self._config & GCDAsyncUdpSocketConfig.kPreferIPv4 ) != 0)
            }) as! Bool
        }
    }

    open func setIPv4Preferred() {
        runBlockAsyncSafely {
            let kPreferIPv6 =  GCDAsyncUdpSocketConfig.kPreferIPv6
            let kPreferIPv4 =  GCDAsyncUdpSocketConfig.kPreferIPv4
            self._config |=  kPreferIPv4;
            self._config &= ~kPreferIPv6;
        }
    }

    open var isIPv6Preferred: Bool {
        get {
            let kPreferIPv6 =  GCDAsyncUdpSocketConfig.kPreferIPv6
            return runSyncWithReturnValue(block: { () -> Any in
                return ((self._config & kPreferIPv6 ) != 0)
            }) as! Bool
        }
    }

    open func setIPv6Preferred() {
        runBlockAsyncSafely {
            let kPreferIPv6 =  GCDAsyncUdpSocketConfig.kPreferIPv6
            let kPreferIPv4 =  GCDAsyncUdpSocketConfig.kPreferIPv4
            self._config |=  kPreferIPv6;
            self._config &= ~kPreferIPv4;
        }
    }

    open var isIPVersionNeutral: Bool {
        get {
            let kPreferIPv6 =  GCDAsyncUdpSocketConfig.kPreferIPv6
            let kPreferIPv4 =  GCDAsyncUdpSocketConfig.kPreferIPv4
            return runSyncWithReturnValue(block: { () -> Any in
                return ((self._config & (kPreferIPv6 | kPreferIPv4) ) != 0)
            }) as! Bool
        }
    }

    open func setIPVersionNeutral() {
        let kPreferIPv6 =  GCDAsyncUdpSocketConfig.kPreferIPv6
        let kPreferIPv4 =  GCDAsyncUdpSocketConfig.kPreferIPv4
        runBlockAsyncSafely {
            self._config &= ~kPreferIPv4;
            self._config &= ~kPreferIPv6;
        }
    }

    /**
     * Gets/Sets the maximum size of the buffer that will be allocated for receive operations.
     * The default maximum size is 65535 bytes.
     *
     * The theoretical maximum size of any IPv4 UDP packet is UINT16_MAX = 65535.
     * The theoretical maximum size of any IPv6 UDP packet is UINT32_MAX = 4294967295.
     *
     * Since the OS/GCD notifies us of the size of each received UDP packet,
     * the actual allocated buffer size for each packet is exact.
     * And in practice the size of UDP packets is generally much smaller than the max.
     * Indeed most protocols will send and receive packets of only a few bytes,
     * or will set a limit on the size of packets to prevent fragmentation in the IP layer.
     *
     * If you set the buffer size too small, the sockets API in the OS will silently discard
     * any extra data, and you will not be notified of the error.
     **/
    open var maxReceiveIPv4BufferSize: UInt {
        get {
            return runSyncWithReturnValue(block: { () -> Any in
                return self._max4ReceiveSize
            }) as! UInt
        }

        set {
            runBlockAsyncSafely {
                self._max4ReceiveSize = newValue;
            }
        }
    }

    open var maxReceiveIPv6BufferSize: UInt {
        get {
            return runSyncWithReturnValue(block: { () -> Any in
                return self._max6ReceiveSize
            }) as! UInt
        }

        set {
            runBlockAsyncSafely {
                self._max6ReceiveSize = newValue;
            }
        }
    }


    /**
     * Gets/Sets the maximum size of the buffer that will be allocated for send operations.
     * The default maximum size is 65535 bytes.
     *
     * Given that a typical link MTU is 1500 bytes, a large UDP datagram will have to be
     * fragmented, and that’s both expensive and risky (if one fragment goes missing, the
     * entire datagram is lost).  You are much better off sending a large number of smaller
     * UDP datagrams, preferably using a path MTU algorithm to avoid fragmentation.
     *
     * You must set it before the sockt is created otherwise it won't work.
     *
     **/
    open var maxSendBufferSize: UInt {
        get {
            return runSyncWithReturnValue(block: { () -> Any in
                return self._maxSendSize
            }) as! UInt
        }
        set {
            runBlockAsyncSafely {
                self._maxSendSize = newValue
            }
        }
    }


    /**
     * User data allows you to associate arbitrary information with the socket.
     * This data is not used internally in any way.
     **/
    open var userData: Any? {
        get {
            return runSyncWithReturnValue(block: { () -> Any? in
                return self._userData
            })
        }
        set {
            runBlockAsyncSafely {
                self._userData = newValue
            }
        }
    }

    func getAddressInfo(block: () -> Any?) -> Any? {
        return runSyncWithReturnValue { () -> Any? in
            if self._socket4FD != InvalidSocket {
                self.maybeUpdateCachedLocalAddress4Info()
            } else {
                self.maybeUpdateCachedLocalAddress6Info()
            }
            return block()
        }
    }
    /**
     * Returns the local address info for the socket.
     *
     * The localAddress method returns a sockaddr structure wrapped in a Data object.
     * The localHost method returns the human readable IP address as a string.
     *
     * Note: Address info may not be available until after the socket has been binded, connected
     * or until after data has been sent.
     **/

    open var localAddres: Data? {
        get {
            return getAddressInfo( block: { () -> Any? in
                if self._socket4FD != InvalidSocket {
                    return self._cachedLocalAddress4
                } else {
                    return self._cachedLocalAddress6
                }
            }) as? Data
        }
    }

    open var localHost: String? {
        get {
            return getAddressInfo( block: { () -> Any? in
                if self._socket4FD != InvalidSocket {
                    return self._cachedLocalHost4
                } else {
                    return self._cachedLocalHost6
                }
            }) as? String
        }
    }

    open var localPort: UInt16 {
        get {
            return getAddressInfo( block: { () -> Any? in
                if self._socket4FD != InvalidSocket {
                    return self._cachedLocalPort4
                } else {
                    return self._cachedLocalPort6
                }
            }) as! UInt16
        }
    }

    open var localAddress_IPv4: Data? {
        get {
            return getAddressInfo( block: { () -> Any? in
                return self._cachedLocalAddress4
            }) as? Data
        }
    }

    open var localHost_IPv4: String? {
        get {
            return getAddressInfo( block: { () -> Any? in
                return self._cachedLocalHost4
            }) as? String
        }
    }

    open var localPort_IPv4: UInt16 {
        get {
            return getAddressInfo( block: { () -> Any? in
                return self._cachedLocalPort4
            }) as! UInt16
        }
    }

    open var localAddress_IPv6: Data? {
        get {
            return getAddressInfo( block: { () -> Any? in
                return self._cachedLocalAddress6
            }) as? Data
        }
    }

    open var localHost_IPv6: String? {
        get {
            return getAddressInfo( block: { () -> Any? in
                return self._cachedLocalHost6
            }) as? String
        }
    }

    open var localPort_IPv6: UInt16 {
        get {
            return getAddressInfo( block: { () -> Any? in
                return self._cachedLocalPort6
            }) as! UInt16
        }
    }

    /**
     * Returns the remote address info for the socket.
     *
     * The connectedAddress method returns a sockaddr structure wrapped in a Data object.
     * The connectedHost method returns the human readable IP address as a string.
     *
     * Note: Since UDP is connectionless by design, connected address info
     * will not be available unless the socket is explicitly connected to a remote host/port.
     * If the socket is not connected, these methods will return nil / 0.
     **/
    open var connectedAddress:  Data? {
        get {
            return getAddressInfo( block: { () -> Any? in
                return self._cachedConnectedAddress
            }) as? Data
        }
    }

    open var connectedHost: String? {
        get {
            return getAddressInfo( block: { () -> Any? in
                return self._cachedConnectedHost
            }) as? String
        }
    }

    open var connectedPort: UInt16 {
        get {
            return getAddressInfo( block: { () -> Any? in
                return self._cachedConnectedHost
            }) as! UInt16
        }
    }


    /**
     * Returns whether or not this socket has been connected to a single host.
     * By design, UDP is a connectionless protocol, and connecting is not needed.
     * If connected, the socket will only be able to send/receive data to/from the connected host.
     **/
    open var isConnected: Bool {
        get {
            return runSyncWithReturnValue( block: { () -> Any in
                return self.didConnect
            }) as! Bool
        }
    }

    /**
     * Returns whether or not this socket has been closed.
     * The only way a socket can be closed is if you explicitly call one of the close methods.
     **/
    open var isClosed: Bool {
        get {
            return runSyncWithReturnValue( block: { () -> Any in
                return !self.didCreateSockets
            }) as! Bool
        }
    }
    
    open var isSock4CanAcceptBytes: Bool {
        get {
            return (self._flags & GCDAsyncUdpSocketFlags.kSock4CanAcceptBytes) != 0
        }
        set {
            let kSock4CanAcceptBytes = GCDAsyncUdpSocketFlags.kSock4CanAcceptBytes
            if newValue {
                self._flags |= kSock4CanAcceptBytes
            } else {
                self._flags &= ~kSock4CanAcceptBytes
            }
        }
    }
    
    open var isSock6CanAcceptBytes: Bool {
        get {
            return (self._flags & GCDAsyncUdpSocketFlags.kSock6CanAcceptBytes) != 0
        }
        set {
            let kSock6CanAcceptBytes = GCDAsyncUdpSocketFlags.kSock6CanAcceptBytes
            if newValue {
                self._flags |= kSock6CanAcceptBytes
            } else {
                self._flags &= ~kSock6CanAcceptBytes
            }
        }
    }

    open var isSend4SourceSuspended: Bool {
        get {
            return runSyncWithReturnValue( block: { () -> Any in
                return (self._flags & GCDAsyncUdpSocketFlags.kSend4SourceSuspended) != 0
            }) as! Bool
        }

        set {
            let kSend4SourceSuspended = GCDAsyncUdpSocketFlags.kSend4SourceSuspended
            if newValue {
                self._flags |= kSend4SourceSuspended
            } else {
                self._flags &= ~kSend4SourceSuspended
            }
        }
    }

    open var isSend6SourceSuspended: Bool {
        get {
            return runSyncWithReturnValue( block: { () -> Any in
                return (self._flags & GCDAsyncUdpSocketFlags.kSend6SourceSuspended) != 0
            }) as! Bool
        }

        set {
            let kSend6SourceSuspended = GCDAsyncUdpSocketFlags.kSend6SourceSuspended
            if newValue {
                self._flags |= kSend6SourceSuspended
            } else {
                self._flags &= ~kSend6SourceSuspended
            }
        }
    }

    open var isReceive4SourceSuspended: Bool {
        get {
            return runSyncWithReturnValue( block: { () -> Any in
                return (self._flags & GCDAsyncUdpSocketFlags.kReceive4SourceSuspended) != 0
            }) as! Bool
        }

        set {
            let kReceive4SourceSuspended = GCDAsyncUdpSocketFlags.kReceive4SourceSuspended
            if newValue {
                self._flags |= kReceive4SourceSuspended
            } else {
                self._flags &= ~kReceive4SourceSuspended
            }
        }
    }

    open var isReceive6SourceSuspended: Bool {
        get {
            return runSyncWithReturnValue( block: { () -> Any in
                return (self._flags & GCDAsyncUdpSocketFlags.kReceive6SourceSuspended) != 0
            }) as! Bool
        }

        set {
            let kReceive6SourceSuspended = GCDAsyncUdpSocketFlags.kReceive6SourceSuspended
            if newValue {
                self._flags |= kReceive6SourceSuspended
            } else {
                self._flags &= ~kReceive6SourceSuspended
            }
        }
    }

    open var isFlipFlop: Bool {
        get {
            return runSyncWithReturnValue( block: { () -> Any in
                return (self._flags & GCDAsyncUdpSocketFlags.kFlipFlop) != 0
            }) as! Bool
        }
    }

    open func toggoleFlipFlop() {
        return runBlockAsyncSafely(block: {
            self._flags ^= GCDAsyncUdpSocketFlags.kFlipFlop
        })
    }

    /**
     * Returns whether or not this socket is IPv4.
     *
     * By default this will be true, unless:
     * - IPv4 is disabled (via setIPv4Enabled:)
     * - The socket is explicitly bound to an IPv6 address
     * - The socket is connected to an IPv6 address
     **/
    open var isIPv4: Bool {
        get {
            return runSyncWithReturnValue( block: { () -> Any in
                if didCreateSockets {
                    return self._socket4FD != InvalidSocket
                } else {
                    return self.isIPv4Enabled
                }
            }) as! Bool
        }
    }

    /**
     * Returns whether or not this socket is IPv6.
     *
     * By default this will be true, unless:
     * - IPv6 is disabled (via setIPv6Enabled:)
     * - The socket is explicitly bound to an IPv4 address
     * _ The socket is connected to an IPv4 address
     *
     * This method will also return false on platforms that do not support IPv6.
     * Note: The iPhone does not currently support IPv6.
     **/
    open var isIPv6: Bool {
        get {
            return runSyncWithReturnValue( block: { () -> Any in
                if didCreateSockets {
                    return self._socket6FD != InvalidSocket
                } else {
                    return self.isIPv6Enabled
                }
            }) as! Bool
        }
    }

    var didBind: Bool {
        get {
            return (self._flags & GCDAsyncUdpSocketFlags.kDidBind) != 0
        }
        set {
            if newValue {
                self._flags |= GCDAsyncUdpSocketFlags.kDidBind
            } else {
                self._flags &= ~GCDAsyncUdpSocketFlags.kDidBind
            }
        }
    }
    
    var shouldCloseAfterSends: Bool {
        get {
            return (self._flags & GCDAsyncUdpSocketFlags.kCloseAfterSends) != 0
        }
        set {
            if newValue {
                self._flags |= GCDAsyncUdpSocketFlags.kCloseAfterSends
            } else {
                self._flags &= ~GCDAsyncUdpSocketFlags.kCloseAfterSends
            }
        }
    }
    
    var isConnecting: Bool {
        get {
            return (self._flags & GCDAsyncUdpSocketFlags.kConnecting) != 0
        }
        set {
            if newValue {
                self._flags |= GCDAsyncUdpSocketFlags.kConnecting
            } else {
                self._flags &= ~GCDAsyncUdpSocketFlags.kConnecting
            }
        }
    }
    
    var isIPv4Deactivated: Bool {
        get {
            return (self._flags & GCDAsyncUdpSocketFlags.kIPv4Deactivated) != 0
        }
        set {
            if newValue {
                self._flags |= GCDAsyncUdpSocketFlags.kIPv4Deactivated
            } else {
                self._flags &= ~GCDAsyncUdpSocketFlags.kIPv4Deactivated
            }
        }
    }
    
    var isIPv6Deactivated: Bool {
        get {
            return (self._flags & GCDAsyncUdpSocketFlags.kIPv6Deactivated) != 0
        }
        set {
            if newValue {
                self._flags |= GCDAsyncUdpSocketFlags.kIPv6Deactivated
            } else {
                self._flags &= ~GCDAsyncUdpSocketFlags.kIPv6Deactivated
            }
        }
    }

    var connecting : Bool {
        return (self._flags & GCDAsyncUdpSocketFlags.kConnecting) != 0
    }

    var didConnect : Bool {
        get { return (self._flags & GCDAsyncUdpSocketFlags.kDidConnect) != 0 }
        set {
            if newValue {
                self._flags |= GCDAsyncUdpSocketFlags.kDidConnect
            } else {
                self._flags &= ~GCDAsyncUdpSocketFlags.kDidConnect
            }
        }
    }

    var isIPv4Disabled: Bool {
        get { return (self._config & GCDAsyncUdpSocketConfig.kIPv4Disabled) != 0 }
        set {
            if newValue {
                self._config |= GCDAsyncUdpSocketConfig.kIPv4Disabled
            } else {
                self._config &= ~GCDAsyncUdpSocketConfig.kIPv4Disabled
            }
        }
    }

    var isIPv6Disabled: Bool {
        get {
            return (self._config & GCDAsyncUdpSocketConfig.kIPv6Disabled) != 0
        }
        set {
            if newValue {
                self._config |= GCDAsyncUdpSocketConfig.kIPv6Disabled
            } else {
                self._config &= ~GCDAsyncUdpSocketConfig.kIPv6Disabled
            }
        }
    }

    var didCreateSockets: Bool {
        get { return (self._flags & GCDAsyncUdpSocketFlags.kDidCreateSockets) != 0 }
        set {
            if newValue {
                self._flags |= GCDAsyncUdpSocketFlags.kDidCreateSockets
            } else {
                self._flags &= ~GCDAsyncUdpSocketFlags.kDidCreateSockets
            }
        }
    }

    var isReceiveContinuous: Bool {
        get { return (self._flags & GCDAsyncUdpSocketFlags.kReceiveContinuous) != 0 }
        set {
            if newValue {
                self._flags |= GCDAsyncUdpSocketFlags.kReceiveContinuous
            } else {
                self._flags &= ~GCDAsyncUdpSocketFlags.kReceiveContinuous
            }
        }
    }

    var isReceiveOnce: Bool {
        get { return (self._flags & GCDAsyncUdpSocketFlags.kReceiveOnce) != 0 }
        set {
            if newValue {
                self._flags |= GCDAsyncUdpSocketFlags.kReceiveOnce
            } else {
                self._flags &= ~GCDAsyncUdpSocketFlags.kReceiveOnce
            }
        }
    }

    /**
     * These methods are only available from within the context of a performBlock: invocation.
     * See the documentation for the performBlock: method above.
     *
     * Provides access to the socket's file descriptor(s).
     * If the socket isn't connected, or explicity bound to a particular interface,
     * it might actually have multiple internal socket file descriptors - one for IPv4 and one for IPv6.
     **/
    open var socketFD: Int32 {
        get {
            if isSocketQueue {
                return InvalidSocket;
            }

            if (_socket4FD != InvalidSocket) {
                return _socket4FD;
            } else {
                return _socket6FD;
            }
        }
    }

    open var socket4FD: Int32 {
        get {
            return _socket4FD
        }
    }

    open var socket6FD: Int32 {
        get {
            return _socket6FD
        }
    }
    
    // MARK: Broadcast
    
    
    open var isBroadcastEnabled: Bool {
        get {
            return runSyncWithReturnValue(block: { () -> Any in
                return ((self._config & GCDAsyncUdpSocketConfig.kIPv6Disabled ) == 0)
            }) as! Bool
        }
        set {
            runBlockAsyncSafely {
                if newValue {
                    self._config &= ~GCDAsyncUdpSocketConfig.kIPv6Disabled
                } else {
                    self._config |= GCDAsyncUdpSocketConfig.kIPv6Disabled
                }
            }
        }
    }
    
    open func enableBroadcast(_ flag: Bool) throws {
        let   block = {
            try self.preOp()
            if !self.didCreateSockets {
                try self.createSockets()
            }
            
            var value : UInt = flag ? 1 : 0
            
            if self.socket4FD != InvalidSocket {
                let status = setsockopt(self.socket4FD, SOL_SOCKET, SO_BROADCAST, &value, socklen_t(MemoryLayout.size(ofValue: value)))
                if (status == -1){
                    Darwin.close(self.socketFD);
                    throw GCDAsyncUdpSocketError.CreateError(
                        GCDAsyncUdpSocket.errorMessageWithReason(reason: "Error in setsockopt() function"))
                }
            }
            
        }
        
        try runSyncWithoutReturnValue(block: block)
    }
}

