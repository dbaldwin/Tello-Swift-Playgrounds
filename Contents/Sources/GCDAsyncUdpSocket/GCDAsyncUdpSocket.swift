//
//  GCDAsyncUdpSocket.swift
//  GCDAsyncUdpSocket-Swift
//
//  Created by XIAOWEI WANG on 18/05/2018.
//  Copyright © 2018 XIAOWEI WANG(mooosu@hotmail.com).
//  Inspired by CocoaAsyncSocket.
//  All rights reserved.
//



import Foundation
import Dispatch
#if os(iOS)
    import UIKit
#endif

public enum GCDAsyncUdpSocketError: Error {

    case CreateError(String)
    case RecvError(String)
    case SendError(String)
    case DataFormat(String)

    case ClosedError(String)
    case OtherError(String)

    case TimeoutError(String)

    case SendTimeoutError(String)
    case RecvTimeoutError(String)

    case BadParamError(String)
    case BadConfigError(String)
}

struct GCDAsyncUdpSocketFlags {
    static let kDidCreateSockets        = UInt32(0x00000001)  // If set, the sockets have been created.
    static let kDidBind                 = UInt32(0x00000002)  // If set, bind has been called.
    static let kConnecting              = UInt32(0x00000004)  // If set, a connection attempt is in progress.
    static let kDidConnect              = UInt32(0x00000008)  // If set, socket is connected.
    static let kReceiveOnce             = UInt32(0x00000010)  // If set, one-at-a-time receive is enabled
    static let kReceiveContinuous       = UInt32(0x00000020)  // If set, continuous receive is enabled
    static let kIPv4Deactivated         = UInt32(0x00000040)  // If set, socket4 was closed due to bind or connect on IPv6.
    static let kIPv6Deactivated         = UInt32(0x00000080)  // If set, socket6 was closed due to bind or connect on IPv4.
    static let kSend4SourceSuspended    = UInt32(0x00000100)  // If set, send4Source is suspended.
    static let kSend6SourceSuspended    = UInt32(0x00000200)  // If set, send6Source is suspended.
    static let kReceive4SourceSuspended = UInt32(0x00000400)  // If set, receive4Source is suspended.
    static let kReceive6SourceSuspended = UInt32(0x00000800)  // If set, receive6Source is suspended.
    static let kSock4CanAcceptBytes     = UInt32(0x00001000)  // If set, we know socket4 can accept bytes. If unset, it's unknown.
    static let kSock6CanAcceptBytes     = UInt32(0x00002000)  // If set, we know socket6 can accept bytes. If unset, it's unknown.
    static let kForbidSendReceive       = UInt32(0x00004000)  // If set, no new send or receive operations are allowed to be queued.
    static let kCloseAfterSends         = UInt32(0x00008000)  // If set, close as soon as no more sends are queued.
    static let kFlipFlop                = UInt32(0x00010000)  // Used to alternate between IPv4 and IPv6 sockets.
    #if TARGET_OS_IPHONE
    static let kAddedStreamListener     = UInt32(0x00020000)  // If set, CFStreams have been added to listener thread
    #endif
};

struct GCDAsyncUdpSocketConfig {
    static let kIPv4Disabled  = UInt32(1)  // If set, IPv4 is disabled
    static let kIPv6Disabled  = UInt32(2)  // If set, IPv6 is disabled
    static let kPreferIPv4    = UInt32(4)  // If set, IPv4 is preferred over IPv6
    static let kPreferIPv6    = UInt32(8)  // If set, IPv6 is preferred over IPv4
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


public class GCDAsyncUdpSendPacket {
    public var buffer: Data
    public var timeout: TimeInterval
    public var tag: Int

    public var resolveInProgress: Bool = false
    public var filterInProgress: Bool = false

    public var resolvedAddresses: Array<Data> = Array<Data>()
    public var resolveError: Error? = nil

    public var address: Data? = nil
    public var addressFamily: sa_family_t = sa_family_t(Darwin.AF_INET)
    /**
     * Initialize GCDAsyncUdpSendPacket
     *
     * This method cannot be used with a connected socket.
     * @param data
     *     The data to send.
     *     If data is nil or zero-length, this method does nothing.
     *     If passing NSMutableData, please read the thread-safety notice below.
     *
     * @param timeout
     *    The timeout for the send opeartion.
     *    If the timeout value is negative, the send operation will not use a timeout.
     **/
    public init(data: Data, timeout: TimeInterval, tag: Int) {
        self.buffer = data
        self.timeout = timeout
        self.tag = tag

        resolveInProgress = false
    }
}

public class GCDAsyncUdpSpecialPacket {

    public var resolveInProgress: Bool = false
    public var addresses: Array<Data> = Array<Data>()
    public var error: Error? = nil
    public init() {
    }
}

import Dispatch


let InvalidSocket = Int32(-1)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
open class GCDAsyncUdpSocket {

    var _delegate: GCDAsyncUdpSocketDelegate?
    var _delegateQueue: DispatchQueue?

    var _receiveFilterBlock: GCDAsyncUdpSocketReceiveFilterBlock?
    var _receiveFilterQueue: DispatchQueue?
    var _receiveFilterAsync: Bool = false

    var _sendFilterBlock: GCDAsyncUdpSocketSendFilterBlock?
    var _sendFilterQueue: DispatchQueue?
    var _sendFilterAsync: Bool = false

    var _flags: UInt32 = 0
    var _config: UInt32 = 0

    var _max4ReceiveSize: UInt = 65535
    var _max6ReceiveSize: UInt = 65535

    var _maxSendSize: UInt = 65535

    var _socket4FD: Int32 = -1
    var _socket6FD: Int32 = -1

    var _socketQueue: DispatchQueue!

    var _send4Source: DispatchSourceWrite?   = nil
    var _send6Source: DispatchSourceWrite?   = nil
    var _receive4Source: DispatchSourceRead? = nil
    var _receive6Source: DispatchSourceRead? = nil
    var _sendTimer: DispatchSourceTimer?     = nil

    var _currentSend: Any?                   = nil
    var _sendQueue: Array<Any> = Array<Any>()

    var _socket4FDBytesAvailable: UInt = 0
    var _socket6FDBytesAvailable: UInt = 0

    var _pendingFilterOperations: UInt32 = 0

    var _cachedLocalAddress4: Data?
    var _cachedLocalHost4: String?
    var _cachedLocalPort4: UInt16? = 0

    var _cachedLocalAddress6: Data?
    var _cachedLocalHost6: String?
    var _cachedLocalPort6: UInt16? = 0

    var _cachedConnectedAddress: Data?
    var _cachedConnectedHost: String?
    var _cachedConnectedPort: UInt16 = 0
    var _cachedConnectedFamily: Int32 = AF_INET

    let _IsOnSocketQueueOrTargetQueueKey = DispatchSpecificKey<()>()

#if TARGET_OS_IPHONE
    var _streamContext: CFStreamClientContext?
    var _readStream4:   CFReadStream?
    var _readStream6:   CFReadStream?
    var _writeStream4:  CFWriteStream?
    var _writeStream6:  CFWriteStream?
#endif
    
    var _userData: Any? = nil

    /**
     * GCDAsyncUdpSocket uses the standard delegate paradigm,
     * but executes all delegate callbacks on a given delegate dispatch queue.
     * This allows for maximum concurrency, while at the same time providing easy thread safety.
     *
     * You MUST set a delegate AND delegate dispatch queue before attempting to
     * use the socket, or you will get an error.
     *
     * The socket queue is optional.
     * If you pass NULL, GCDAsyncSocket will automatically create its own socket queue.
     * If you choose to provide a socket queue, the socket queue must not be a concurrent queue,
     * then please see the discussion for the method markSocketQueueTargetQueue.
     *
     * The delegate queue and socket queue can optionally be the same.
     **/
    public convenience init() {
        self.init(socketQueue: nil)
    }

    public convenience init(socketQueue sq: DispatchQueue?) {
        self.init(delegate: nil, delegateQueue: nil, socketQueue: sq)
    }

    public convenience init(delegate aDelegate: GCDAsyncUdpSocketDelegate?, delegateQueue dq: DispatchQueue?) {
        self.init(delegate: aDelegate, delegateQueue: dq, socketQueue: nil)
    }

    public init(delegate aDelegate: GCDAsyncUdpSocketDelegate?, delegateQueue dq: DispatchQueue?, socketQueue sq: DispatchQueue?) {
        self._delegate = aDelegate
        self._delegateQueue = dq
        self._socketQueue = sq

        self._max4ReceiveSize = 65535
        self._max6ReceiveSize = 65535

        self._maxSendSize = 65535

        self._socket4FD = InvalidSocket;
        self._socket6FD = InvalidSocket;

        if self._socketQueue == nil {
            self._socketQueue = DispatchQueue(label: "GCDAsyncUdpSocket")
        }
        self._socketQueue.setSpecific(key: _IsOnSocketQueueOrTargetQueueKey, value: ())
        
        #if TARGET_OS_IPHONE
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.willEnterForegroundNotification(notification:)),
                name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        #endif
    }
    
    deinit {
        #if TARGET_OS_IPHONE
            NotificationCenter.default.removeObserver(self)
        #endif
        
        runBlockSyncSafely {
            self.closeWithError(error: nil)
        }
        
        _delegate = nil
        _delegateQueue = nil
        _socketQueue = nil
    }

    @objc func willEnterForegroundNotification(notification: Notification ) {
        print("willEnterForegroundNotification")
    }
}

