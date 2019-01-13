//
//  SocketError.swift
//  GCDAsyncUdpSocket-Swift
//
//  Created by XIAOWEI WANG on 18/05/2018.
//  Copyright © 2018 XIAOWEI WANG(mooosu@hotmail.com).
//  Inspired by CocoaAsyncSocket.
//  All rights reserved.
//
import Foundation

typealias  addrinfo_pointer = UnsafeMutablePointer<addrinfo>
typealias  sockaddr_in_pointer = UnsafeMutablePointer<sockaddr_in>

public enum SocketError: Error {
    case SettingError(String)
    case OpenError(String)
    case RecvError(String)
    case SendError(String)
    case DataFormat(String)
    case TimeoutError(String)
    case OtherError(String)
}
