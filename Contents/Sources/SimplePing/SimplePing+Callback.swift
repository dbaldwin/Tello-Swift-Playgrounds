//
//  SimplePing.swift
//  SimplePing
//
//  Created by XIAOWEI WANG on 2018/8/13.
//  Copyright © 2018 XIAOWEI WANG. All rights reserved.
//

import Foundation
extension SimplePing {
    static func SocketReadCallback(s: CFSocket?, type: CFSocketCallBackType,  address: CFData?, data: UnsafeRawPointer?, info: UnsafeRawPointer?) {
        let pinger = unsafeBitCast(info, to: SimplePing.self)
        pinger.readData()
    }
    
    static func HostResolveCallback( theHost: CFHost,  typeInfo: CFHostInfoType, error: UnsafePointer<CFStreamError>?, info: UnsafeMutableRawPointer?) -> Void {
        let pinger = unsafeBitCast(info, to: SimplePing.self)
        if error != nil && error!.pointee.domain != 0 {
            pinger.didFail(withHostStreamError: error!.pointee)
        } else {
            pinger.hostResolutionDone()
        }
    }
}
