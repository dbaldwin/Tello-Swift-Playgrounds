//
//  GCDAsyncUdpSocket+BindingSockets.swift
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

    func preOp() throws {
        if self._delegate == nil {
            throw GCDAsyncUdpSocketError.BadConfigError("Attempting to use socket without a delegate. Set a delegate first.")
        }
        
        if self._delegateQueue == nil {
            throw GCDAsyncUdpSocketError.BadConfigError("Attempting to use socket without a delegate queue. Set a delegate queue first.")
        }
    }
    // --done --
    func preBind() throws {

        try preOp()
        
        if self.didBind {
            throw GCDAsyncUdpSocketError.BadConfigError("Cannot bind a socket more than once.")
        }
        
        if self.connecting || self.didConnect {
            throw GCDAsyncUdpSocketError.BadConfigError("Cannot bind after connecting. If needed, bind first, then connect.")
        }
        
        if (self.isIPv4Disabled && self.isIPv6Disabled) {
            throw GCDAsyncUdpSocketError.BadConfigError("Both IPv4 and IPv6 have been disabled. Must enable at least one protocol first.")
        }
    }

    // --done --
    open func bind(toPort port: UInt16) throws {
        try bind(toPort: port, interface: nil)
    }

    // --done --
    open func bind(toPort port: UInt16, interface: String?) throws {
        let block =  {
            try self.preBind()
            
            let (addr4, addr6) = GCDAsyncUdpSocket.convertIntefaceDescription(interfaceDescription: interface, port: port)
            if addr4 == nil && addr6 == nil {
                throw GCDAsyncUdpSocketError.BadParamError(
                    "Unknown interface. Specify valid interface by name (e.g. \"en1\") or IP address.")
            }
            
            if (self.isIPv4Disabled && (addr6 == nil)) {
                throw GCDAsyncUdpSocketError.BadParamError(
                    "IPv4 has been disabled and specified interface doesn't support IPv6.")
            }
            
            if (self.isIPv6Disabled && (addr4 == nil)) {
                throw GCDAsyncUdpSocketError.BadParamError(
                    "IPv6 has been disabled and specified interface doesn't support IPv4.")
            }
            
            let useIPv4 = !self.isIPv4Disabled && (addr4 != nil)
            let useIPv6 = !self.isIPv6Disabled && (addr6 != nil)
            
            var status: Int32 = -1
            if !self.didCreateSockets {
                if useIPv4 {
                    try self.createSocket4()
                    addr4?.withUnsafeBytes({ (pointer:UnsafePointer<sockaddr>) in
                         status = Darwin.bind(self._socket4FD, pointer, socklen_t(addr4!.count))
                    })
                    if (status == -1) {
                        self.closeSockets()
                        throw GCDAsyncUdpSocketError.CreateError(GCDAsyncUdpSocket.errorMessageWithReason(reason: "Error in bind(4) function."))
                    }
                    self.didCreateSockets =  true
                    self.setupSendAndReceiveSourcesForSocket4()
                }

                if useIPv6 {
                    try self.createSocket6()
                    addr6?.withUnsafeBytes({ (pointer:UnsafePointer<sockaddr>) in
                        status = Darwin.bind(self._socket6FD, pointer, socklen_t(addr6!.count))
                    })
                    if (status == -1) {
                        self.closeSockets()
                        throw GCDAsyncUdpSocketError.CreateError(GCDAsyncUdpSocket.errorMessageWithReason(reason: "Error in bind(6) function."))
                    }
                    self.didCreateSockets =  true
                    self.setupSendAndReceiveSourcesForSocket6()
                }
            }

            self.didBind = true
            self.isIPv4Deactivated = !useIPv4
            self.isIPv6Deactivated = !useIPv6
        }
        
        try runSyncWithoutReturnValue {
            try block()
        }
    }
    
    
    /**
     * Binds the UDP socket to the given address, specified as a sockaddr structure wrapped in a Data object.
     *
     * If you have an existing struct sockaddr you can convert it to a Data object like so:
     * struct sockaddr sa  -> Data *dsa = [Data dataWithBytes:&remoteAddr length:remoteAddr.sa_len];
     * struct sockaddr *sa -> Data *dsa = [Data dataWithBytes:remoteAddr length:remoteAddr->sa_len];
     *
     * Binding should be done for server sockets that receive data prior to sending it.
     * Client sockets can skip binding,
     * as the OS will automatically assign the socket an available port when it starts sending data.
     *
     * You cannot bind a socket after its been connected.
     * You can only bind a socket once.
     * You can still connect a socket (if desired) after binding.
     *
     * On success, returns YES.
     * Otherwise returns NO, and sets errPtr. If you don't care about the error, you can pass NULL for errPtr.
     **/
    open func bind(toAddress localAddr: Data) throws {
        let block =  {
            try self.preBind()
            
            let family = GCDAsyncUdpSocket.family(fromAddress: localAddr)
            guard family != AF_UNSPEC else {
                throw GCDAsyncUdpSocketError.BadParamError(
                    "A valid IPv4 or IPv6 address was not given")
            }
            
            let addr4 = (family == AF_INET) ? localAddr : nil
            let addr6 = (family == AF_INET6) ? localAddr : nil

            if self.isIPv4Disabled && addr4 != nil{
                throw GCDAsyncUdpSocketError.BadParamError(
                    "IPv4 has been disabled and an IPv4 address was passed.")
            }

            if self.isIPv6Disabled && addr6 != nil{
                throw GCDAsyncUdpSocketError.BadParamError(
                    "IPv4 has been disabled and an IPv4 address was passed.")
            }

            let useIPv4 = !self.isIPv4Disabled && (addr4 != nil)
            let useIPv6 = !self.isIPv6Disabled && (addr6 != nil)

            var status: Int32 = -1
            if !self.didCreateSockets {
                if useIPv4 {
                    print(String(format: "Binding socket to address(%@:%d)",
                                 GCDAsyncUdpSocket.host(fromAddress: addr4!) ?? "",
                                GCDAsyncUdpSocket.port(fromAddress: addr4!)))

                    try self.createSocket4()
                    addr4?.withUnsafeBytes({ (pointer:UnsafePointer<sockaddr>) in
                        status = Darwin.bind(self._socket4FD, pointer, socklen_t(addr4!.count))
                    })
                    if (status == -1) {
                        self.closeSockets()
                        throw GCDAsyncUdpSocketError.CreateError(GCDAsyncUdpSocket.errorMessageWithReason(reason: "Error in bind(4) function."))
                    }
                    self.didCreateSockets =  true
                    self.setupSendAndReceiveSourcesForSocket4()
                }
                
                if useIPv6 {
                    print(String(format: "Binding socket to address(%@:%d)",
                                 GCDAsyncUdpSocket.host(fromAddress: addr4!) ?? "",
                                 GCDAsyncUdpSocket.port(fromAddress: addr4!)))
                    
                    try self.createSocket6()
                    addr6?.withUnsafeBytes({ (pointer:UnsafePointer<sockaddr>) in
                        status = Darwin.bind(self._socket6FD, pointer, socklen_t(addr6!.count))
                    })
                    if (status == -1) {
                        self.closeSockets()
                        throw GCDAsyncUdpSocketError.CreateError(GCDAsyncUdpSocket.errorMessageWithReason(reason: "Error in bind(6) function."))
                    }
                    self.didCreateSockets =  true
                    self.setupSendAndReceiveSourcesForSocket6()
                }
            }
            
            self.didBind = true
            self.isIPv4Deactivated = !useIPv4
            self.isIPv6Deactivated = !useIPv6
        }
        
        try runSyncWithoutReturnValue {
            try block()
        }
    }
}

