//
//  SimplePing.swift
//  SimplePing
//
//  Created by XIAOWEI WANG on 2018/8/13.
//  Copyright © 2018 XIAOWEI WANG. All rights reserved.
//

import Foundation
extension SimplePing {
    static func in_cksum(data: [UInt8]) -> UInt16 {
        var sum: UInt32 = 0
        var bytesLeft = data.count
        var index = 0
        while bytesLeft > 1 {
            let uint16: UInt16 = UInt16(UInt16(data[index + 1]) << 8 | UInt16(data[index]))
            sum += UInt32(uint16)
            index += 2
            bytesLeft -= 2
        }

        if bytesLeft == 1 {
            let last: UInt16 = UInt16(data[index])
            sum += UInt32(last)
        }

        sum = (sum >> 16 ) + ( sum & 0xffff )
        sum += ( sum >> 16 )
        return UInt16(~sum & 0xffff)
    }
}
