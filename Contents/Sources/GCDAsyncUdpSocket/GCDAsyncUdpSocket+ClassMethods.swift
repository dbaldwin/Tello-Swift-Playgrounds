//
//  GCDAsyncUdpSocket+ClassMethods.swift
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

fileprivate var int_size : Int {
    return MemoryLayout.size(ofValue: Int())
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
extension GCDAsyncUdpSocket {
    
    class func createSocketByVersion(family: Int32) throws -> Int32 {
        let socketFD = socket(family, SOCK_DGRAM, 0);
        
        if (socketFD == InvalidSocket) {
            throw GCDAsyncUdpSocketError.CreateError(errorMessageWithReason(reason: "Error in socket() function"))
        }
        
        // Set socket options
        
        var status = fcntl(socketFD, F_SETFL, O_NONBLOCK);
        if (status == -1) {
            Darwin.close(socketFD);
            throw GCDAsyncUdpSocketError.CreateError(errorMessageWithReason(reason: "Error enabling non-blocking IO on socket (fcntl)"))
        }
        
        var reuseaddr = 1;
        status = setsockopt(socketFD, SOL_SOCKET, SO_REUSEADDR, &reuseaddr, socklen_t(MemoryLayout.size(ofValue: reuseaddr)));
        if (status == -1) {
            Darwin.close(socketFD);
            throw GCDAsyncUdpSocketError.CreateError(errorMessageWithReason(reason: "Error enabling address reuse (setsockopt)"))
        }
        
        var nosigpipe = 1;
        status = setsockopt(socketFD, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, socklen_t(MemoryLayout.size(ofValue: nosigpipe)))
        if (status == -1) {
            Darwin.close(socketFD);
            throw GCDAsyncUdpSocketError.CreateError(errorMessageWithReason(reason: "Error disabling sigpipe (setsockopt)"))
        }

        return socketFD;
    }

    /**
     * Extracting host/port/family information from raw address data.
     **/
    open class func host(fromAddress address: Data) -> String? {
        let (address, _, _) = getHost(fromAddress: address)
        return address
    }
    
    open class func port(fromAddress address: Data) -> UInt16 {
        let (_, port, _) = getHost(fromAddress: address)
        return port
    }
    
    open class func family(fromAddress address: Data) -> UInt8 {
        let (_, _, af) = getHost(fromAddress: address)
        return af
    }
    
    open class func isIPv4Address(_ address: Data) -> Bool {
        let (_, _, af) = getHost(fromAddress: address)
        return af == AF_INET
    }
    
    open class func isIPv6Address(_ address: Data) -> Bool {
        let (_, _, af) = getHost(fromAddress: address)
        return af == AF_INET6
    }

    open class func hostFromSockaddr4(addr_in: UnsafeMutablePointer<sockaddr_in>) -> String {
        let bufferSize = 64
        let stringAddress = UnsafeMutablePointer<Int8>.allocate(capacity: bufferSize)
        defer {
            stringAddress.deallocate()
        }
        if inet_ntop(AF_INET, &addr_in.pointee.sin_addr, stringAddress, socklen_t(bufferSize)) == nil {
            stringAddress[0] = 0
        }
        return String(cString: stringAddress)
    }
    
    open class func portFromSockaddr4(addr_in: UnsafeMutablePointer<sockaddr_in>) -> UInt16 {
        return _OSSwapInt16(addr_in.pointee.sin_port)
    }

    open class func hostFromSockaddr6(addr_in: UnsafeMutablePointer<sockaddr_in6>) -> String {
        let bufferSize = 128
        let stringAddress = UnsafeMutablePointer<Int8>.allocate(capacity: bufferSize)
        defer {
            stringAddress.deallocate()
        }
        if inet_ntop(AF_INET6, &addr_in.pointee.sin6_addr, stringAddress, socklen_t(bufferSize)) == nil {
            stringAddress[0] = 0
        }
        return String(cString: stringAddress)
    }
    
    open class func portFromSockaddr6(addr_in: UnsafeMutablePointer<sockaddr_in6>) -> UInt16 {
        return _OSSwapInt16(addr_in.pointee.sin6_port)
    }
    
    open class func compareSockaddrIn4(addr1: Data, addr2: Data) -> Bool {
        var result = false
        
        var a1 = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
        var a2 = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
        
        defer {
            a1.deallocate()
            a2.deallocate()
        }
        
        a1.withMemoryRebound(to: UInt8.self, capacity: sockaddr_in_size, { (pointer) in
            addr1.copyBytes(to: pointer, count: sockaddr_in_size)
        })
        
        a2.withMemoryRebound(to: UInt8.self, capacity: sockaddr_in_size, { (pointer) in
            addr2.copyBytes(to: pointer, count: sockaddr_in_size)
        })
        
        if 0 == memcmp(&a1.pointee.sin_addr, &a2.pointee.sin_addr, MemoryLayout.size(ofValue: a1.pointee.sin_addr)) {
            if 0 == memcmp(&a1.pointee.sin_port, &a2.pointee.sin_port, MemoryLayout.size(ofValue: a1.pointee.sin_port)) {
                result = true
            }
        }
        return result
    }
    
    open class func compareSockaddrIn6(addr1: Data, addr2: Data) -> Bool {
        var result = false
        
        var a1 = UnsafeMutablePointer<sockaddr_in6>.allocate(capacity: 1)
        var a2 = UnsafeMutablePointer<sockaddr_in6>.allocate(capacity: 1)
        
        defer {
            a1.deallocate()
            a2.deallocate()
        }
        
        a1.withMemoryRebound(to: UInt8.self, capacity: sockaddr_in6_size, { (pointer) in
            addr1.copyBytes(to: pointer, count: sockaddr_in6_size)
        })
        
        a2.withMemoryRebound(to: UInt8.self, capacity: sockaddr_in6_size, { (pointer) in
            addr2.copyBytes(to: pointer, count: sockaddr_in6_size)
        })
        
        if 0 == memcmp(&a1.pointee.sin6_addr, &a2.pointee.sin6_addr, MemoryLayout.size(ofValue: a1.pointee.sin6_addr)) {
            if 0 == memcmp(&a1.pointee.sin6_port, &a2.pointee.sin6_port, MemoryLayout.size(ofValue: a1.pointee.sin6_port)) {
                result = true
            }
        }
        return result
    }
    
    
    class func getLocalAddress(socketFD: Int32, family: Int32) -> (Data?, String?, UInt16?) {
        var addr : Data? = nil
        var host: String? = nil
        var port: UInt16? = nil
        
        if family == AF_INET {
            var in4 = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
            defer {
                in4.deallocate()
            }
            var sockaddr4len = socklen_t(sockaddr_in_size)
            in4.withMemoryRebound(to: sockaddr.self, capacity: 1, { (pointer)  in
                if getsockname(socketFD, pointer, &sockaddr4len) == 0 {
                    addr = Data(bytes: pointer, count: sockaddr_in_size)
                    host = GCDAsyncUdpSocket.hostFromSockaddr4(addr_in: in4)
                    port = GCDAsyncUdpSocket.portFromSockaddr4(addr_in: in4)
                }
            })
        } else if family == AF_INET6 {
            var in6 = UnsafeMutablePointer<sockaddr_in6>.allocate(capacity: 1)
            defer {
                in6.deallocate()
            }
            var sockaddr6len = socklen_t(sockaddr_in6_size)
            in6.withMemoryRebound(to: sockaddr.self, capacity: 1, { (pointer)  in
                if getsockname(socketFD, pointer, &sockaddr6len) == 0 {
                    addr = Data(bytes: pointer, count: sockaddr_in6_size)
                    host = GCDAsyncUdpSocket.hostFromSockaddr6(addr_in: in6)
                    port = GCDAsyncUdpSocket.portFromSockaddr6(addr_in: in6)
                }
            })
        }
        return (addr, host, port)
    }
    
    open class func getBroadcastAddress(interfaceDescription: String, port: UInt16) ->  (Data?)  {
        let (addr4, _) = GCDAsyncUdpSocket.convertIntefaceDescription(interfaceDescription: interfaceDescription, port: port)
        let (host4, _, _) = GCDAsyncUdpSocket.getHost(fromAddress: addr4!)
        
        var parts = host4.split(separator: ".")
        parts[3] = "255"
        let broadcastAddrString = parts.joined(separator: ".")
        
        let broadcastAddr = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
        defer {
            broadcastAddr.deallocate()
        }
        broadcastAddr.withMemoryRebound(to: UInt8.self, capacity: sockaddr_size, { (pointer) in
            addr4!.copyBytes(to: pointer, count: sockaddr_size)
        })
        
        let retval = inet_pton(AF_INET, broadcastAddrString, &broadcastAddr.pointee.sin_addr)
        var result: Data? = nil
        
        if retval == 0 {
            print("Invalid address")
        } else if retval == -1 {
            print("Failed:", String(cString: strerror(errno)))
        } else {
            result = Data.init(bytes: broadcastAddr, count: sockaddr_size)
        }
        return result
    }
    
    open class func addressAndPortToData(stringAddress: String, port: UInt16, interfaceDescription: String = "en0") -> Data? {
        var result: Data? = nil
        let (addr4, _) = GCDAsyncUdpSocket.convertIntefaceDescription(interfaceDescription: interfaceDescription, port: port)
        guard let addr = addr4 else {
            return result
        }

        let address = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
        defer {
            address.deallocate()
        }
        
        address.withMemoryRebound(to: UInt8.self, capacity: sockaddr_size, { (pointer) in
            addr4!.copyBytes(to: pointer, count: sockaddr_size)
        })
        
        let retval = inet_pton(AF_INET, stringAddress, &address.pointee.sin_addr)
        if retval == 0 {
            assert(false, "Invalid address")
        } else if retval == -1 {
            assert(false,  String(cString: strerror(errno)))
        } else {
            result = Data(bytes: address, count: sockaddr_size)
        }
        return result
    }
    
    open class func getSubnetAddresses(interfaceDescription: String?, port: UInt16) -> [Data]  {
        var addresses = [Data]()
        let (addr4, _) = GCDAsyncUdpSocket.convertIntefaceDescription(interfaceDescription: interfaceDescription, port: port)
        guard let addr = addr4 else {
            return addresses
        }
        let (host4, _, _) = GCDAsyncUdpSocket.getHost(fromAddress: addr4!)
        
        var parts = host4.split(separator: ".")
        parts.removeLast()
        
        var subnet = parts.joined(separator: ".")
        let address = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
        defer {
            address.deallocate()
        }
        address.withMemoryRebound(to: UInt8.self, capacity: sockaddr_size, { (pointer) in
            addr4!.copyBytes(to: pointer, count: sockaddr_size)
        })
        
        for i in 1 ..< 255  {
            let stringAddress = String(format: "%@.%d", subnet, i)
            let retval = inet_pton(AF_INET, stringAddress, &address.pointee.sin_addr)
            if retval == 0 {
                print("Invalid address")
            } else if retval == -1 {
                print("Failed:", String(cString: strerror(errno)))
            } else {
                addresses.append(Data(bytes: address, count: sockaddr_size))
            }
        }

        return addresses
    }
    
    open class func getHost(fromAddress address: Data) -> (String, UInt16, UInt8) {
        if address.count >= sockaddr_size {
            let addr = UnsafeMutablePointer<sockaddr>.allocate(capacity: 1)
            defer {
                addr.deallocate()
            }
            addr.withMemoryRebound(to: UInt8.self, capacity: sockaddr_size, { (pointer) in
                address.copyBytes(to: pointer, count: sockaddr_size)
            })
            
            if addr.pointee.sa_family == AF_INET {
                let addr_in = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
                addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1, { (pointer) in
                    addr_in.assign(from: pointer, count: 1)
                })
                defer {
                    addr_in.deallocate()
                }
                return (hostFromSockaddr4(addr_in: addr_in), portFromSockaddr4(addr_in: addr_in), addr.pointee.sa_family)
            } else if addr.pointee.sa_family == AF_INET6 {
                let addr_in6 = UnsafeMutablePointer<sockaddr_in6>.allocate(capacity: 1)
                addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1, { (pointer) in
                    addr_in6.assign(from: pointer, count: 1)
                })
                defer {
                    addr_in6.deallocate()
                }
                return (hostFromSockaddr6(addr_in: addr_in6), portFromSockaddr6(addr_in: addr_in6), addr.pointee.sa_family)
            }
        }
        return ("", 0, 0)
    }

    /**
     * Finds the address(es) of an interface description.
     * An inteface description may be an interface name (en0, en1, lo0) or corresponding IP (192.168.4.34).
     **/
    open class func convertIntefaceDescription(interfaceDescription: String?, port: UInt16) -> ( Data?, Data?) {
        var addr4: Data? = nil;
        var addr6: Data? = nil;
        
        if (interfaceDescription == nil)
        {
            // ANY address
            let sockaddr4 = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
            defer {
                sockaddr4.deallocate()
            }
            memset(sockaddr4, 0, sockaddr_in_size)
            
            sockaddr4.pointee.sin_len         = __uint8_t(sockaddr_in_size)
            sockaddr4.pointee.sin_family      = sa_family_t(AF_INET)
            sockaddr4.pointee.sin_port        = _OSSwapInt16(port)
            sockaddr4.pointee.sin_addr.s_addr = _OSSwapInt32(INADDR_ANY)
            
            let sockaddr6 = UnsafeMutablePointer<sockaddr_in6>.allocate(capacity: 1)
            defer {
                sockaddr6.deallocate()
            }
            memset(sockaddr6, 0, sockaddr_in6_size)
            
            sockaddr6.pointee.sin6_len         = __uint8_t(sockaddr_in6_size)
            sockaddr6.pointee.sin6_family      = sa_family_t(AF_INET6)
            sockaddr6.pointee.sin6_port        = _OSSwapInt16(port)
            
            var a6 = in6addr_any
            memcpy(&sockaddr6.pointee.sin6_addr, &a6, in6_addr_size)
            
            addr4 = Data(bytes: sockaddr4, count: sockaddr_in_size)
            addr6 = Data(bytes: sockaddr6, count: sockaddr_in6_size)
        }
        else if interfaceDescription == "localhost" || interfaceDescription  == "loopback" {
            
            let sockaddr4 = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
            defer {
                sockaddr4.deallocate()
            }
            memset(sockaddr4, 0, sockaddr_in_size)
            
            sockaddr4.pointee.sin_len         = __uint8_t(sockaddr_in_size)
            sockaddr4.pointee.sin_family      = sa_family_t(AF_INET)
            sockaddr4.pointee.sin_port        = _OSSwapInt16(port)
            sockaddr4.pointee.sin_addr.s_addr = _OSSwapInt32(INADDR_LOOPBACK)
            
            let sockaddr6 = UnsafeMutablePointer<sockaddr_in6>.allocate(capacity: 1)
            defer {
                sockaddr6.deallocate()
            }
            memset(sockaddr6, 0, sockaddr_in6_size)
            
            sockaddr6.pointee.sin6_len         = __uint8_t(sockaddr_in6_size)
            sockaddr6.pointee.sin6_family      = sa_family_t(AF_INET6)
            sockaddr6.pointee.sin6_port        = _OSSwapInt16(port)
            
            var a6 = in6addr_loopback
            memcpy(&sockaddr6.pointee.sin6_addr, &a6, in6_addr_size)
            
            addr4 = Data(bytes: sockaddr4, count: sockaddr_in_size)
            addr6 = Data(bytes: sockaddr6, count: sockaddr_in6_size)
        } else {
            var addrs : UnsafeMutablePointer<ifaddrs>? = nil
            var cursor : UnsafeMutablePointer<ifaddrs>? = nil
            if  getifaddrs(&addrs) == 0 {
                cursor = addrs;
                var  pAddr = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
                var  pAddr6 = UnsafeMutablePointer<sockaddr_in6>.allocate(capacity: 1)
                let  ip = UnsafeMutablePointer<Int8>.allocate(capacity: 128)
                defer {
                    pAddr.deallocate()
                    pAddr6.deallocate()
                    ip.deallocate()
                }
                while (cursor != nil) {
                    if (addr4 == nil) && (cursor!.pointee.ifa_addr.pointee.sa_family == AF_INET) {
                        // IPv4
                        cursor!.pointee.ifa_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1, { (pointer) in
                            pAddr.assign(from: pointer, count: 1)
                        })
                        let iface = String(cString: cursor!.pointee.ifa_name)
                        if iface == interfaceDescription {
                            // Name match
                            var tmpAddr = pAddr.pointee
                            tmpAddr.sin_port = _OSSwapInt16(port)
                            addr4 = Data(bytes: &tmpAddr, count: sockaddr_in_size)
                        } else {
                            if inet_ntop(AF_INET, &pAddr.pointee.sin_addr, ip, 128) != nil {
                                if String(cString: ip) == interfaceDescription {
                                    // IP match
                                    var tmpAddr = pAddr.pointee
                                    tmpAddr.sin_port = _OSSwapInt16(port)
                                    addr4 = Data(bytes: &tmpAddr, count: sockaddr_in_size)
                                }
                            }
                        }
                    } else if (addr6 == nil) && (cursor!.pointee.ifa_addr.pointee.sa_family == AF_INET6) {
                        // IPv6
                        cursor!.pointee.ifa_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1, { (pointer) in
                            pAddr6.assign(from: pointer, count: 1)
                        })
                        let iface = String(cString: cursor!.pointee.ifa_name)
                        if iface == interfaceDescription {
                            // Name match
                            var tmpAddr6 = pAddr6.pointee
                            tmpAddr6.sin6_port = _OSSwapInt16(port)
                            addr6 = Data(bytes: &tmpAddr6, count: sockaddr_in6_size)
                        } else {
                            if( inet_ntop(AF_INET6, &pAddr6.pointee.sin6_addr, ip, 128) != nil ) {
                                if String(cString: ip) == iface {
                                    // IP match
                                    var tmpAddr6 = pAddr6.pointee
                                    tmpAddr6.sin6_port = _OSSwapInt16(port)
                                    addr6 = Data(bytes: &tmpAddr6, count: sockaddr_in6_size)
                                }
                            }
                        }
                    }
                    cursor = cursor!.pointee.ifa_next
                }
                freeifaddrs(addrs);
            }
        }
        return (addr4, addr6)
    }
}

