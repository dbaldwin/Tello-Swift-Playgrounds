//
//  DroneApi2.swift
//  DroneApi2
//
/*
 
 * @version 1.0
 
 * @date Aug 2018
 
 *
 
 *
 
 * @Copyright (c) 2018 Ryze Tech
 
 *
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 
 * of this software and associated documentation files (the "Software"), to deal
 
 * in the Software without restriction, including without limitation the rights
 
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 
 * copies of the Software, and to permit persons to whom the Software is
 
 * furnished to do so, subject to the following conditions:
 
 *
 
 * The above copyright notice and this permission notice shall be included in
 
 * all copies or substantial portions of the Software.
 
 *
 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 
 * SOFTWARE.
 
 * *
 * Created by XIAOWEI WANG on 14/04/2018.
 * support@ryzerobotics.com
 *
 
 */
import Foundation

public func wait(seconds: UInt) {
    sleep(UInt32(seconds))
}

public func connectAP(ssid: String, password: String) -> Bool {
    return Tello.connectAP(ssid: ssid, password: password)
}

public func getPadID() -> Int {
    Tello.recordAction(action: .getPadID)
    if Tello.ready {
        for _ in 0..<25 {
            if let status = Tello.status {
                let id = status.marker.id
                if id > 0 {
                    DroneLog.debug(String(format: "pad id: %d", id)) //-debug-log
                    _sendToView(value: .dictionary([
                        "action":  .string("getPadID"),
                        "value" :  .integer(id)
                        ]))
                    return status.marker.id
                }
            }
            delay(milliseconds: 500)
        }
    }
    return -2
}

public func getPadPos() -> (x: Float, y: Float, z: Float) {
    Tello.recordAction(action: .getPadPos)
    if Tello.ready {
        for _ in 0..<100 {
            delay(milliseconds: 500)
            if let status = Tello.status, status.marker.id >= 0 && status.marker.id <= 8 {
                _sendToView(value: .dictionary([
                    "action":  .string("getPadPos"),
                    "x" :  .floatingPoint(Double(status.marker.x)),
                    "y" :  .floatingPoint(Double(status.marker.y)),
                    "z" :  .floatingPoint(Double(status.marker.z))
                    ]))
                
                return (x: status.marker.x, y: status.marker.y, z: status.marker.z)
            }
        }
    }
    return  (x: -2, y: -2, z: -2)
}

public func barometer() -> Float {
    if let baro = Tello.puppet.status?.baro {
        return baro
    }
    return -2
}

public func getHeight() -> Float {
    Tello.recordAction(action: .getHeight)
    for _ in 0..<100 {
        delay(milliseconds: 500)
        if let tof = Tello.puppet.status?.tof {
            _sendToView(value: .dictionary([
                "action":  .string("getHeight"),
                "value" :  .floatingPoint(Double(tof))
                ]))
            return tof
        }
    }
    return 0
}

public func getBattery() -> Int {
    if let bat = Tello.puppet.status?.bat {
        return bat
    }
    return -2
}

public func setSpeed(cms: UInt) -> Bool {
    let ret = Tello.setSpeed(cms: cms)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func takeOff() -> Bool {
    let ret = Tello.takeOff()
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func mon() -> Bool {
    return Tello.mon()
}

public func flyUp(cm: UInt) -> Bool {
    let ret = Tello.flyUp(cm: cm)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func flyDown(cm: UInt) -> Bool {
    let ret = Tello.flyDown(cm: cm)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func flyLeft(cm: UInt) -> Bool {
    let ret = Tello.flyLeft(cm: cm)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func flyRight(cm: UInt) -> Bool {
    let ret = Tello.flyRight(cm: cm)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func flyForward(cm: UInt) -> Bool {
    let ret = Tello.flyForward(cm: cm)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func flyBackward(cm: UInt) -> Bool {
    let ret = Tello.flyBackward(cm: cm)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func turnLeft(degree: Int) -> Bool {
    let ret = Tello.turnLeft(degree: degree)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func turnRight(degree: Int) -> Bool {
    let ret = Tello.turnRight(degree: degree)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func flyLine(x: Int, y: Int, z: Int) -> Bool {
    let speed = Tello.getSpeed()
    Tello.recordAction(action: .flyLine(x: x, y: y, z: z, pad: 100))
    let ret = Tello.go(x: x, y: y, z: z, speed: speed)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func flyLine(x: Int, y: Int, z: Int, pad: Int) -> Bool{
    let ret = Tello.flyLine(x: x, y: y, z: z, pad: pad)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func flyCurve(x1: Int, y1: Int, z1: Int, x2: Int,y2: Int, z2: Int) -> Bool {
    Tello.recordAction(action: .flyCurve(x1: x1, y1: y1, z1: z1, x2: x2, y2: y2, z2: z2))
    let speed = Tello.getSpeed()
    let ret = Tello.curve(x1: x1, y1: y1, z1: z1, x2: x2, y2: y2, z2: z2, speed: speed, marker: "")
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func flyCurve(x1: Int, y1: Int, z1: Int, x2: Int,y2: Int, z2: Int, marker: String) -> Bool {
    let speed = Tello.getSpeed()
    Tello.recordAction(action: .flyCurve(x1: x1, y1: y1, z1: z1, x2: x2, y2: y2, z2: z2))
    let ret = Tello.curve(x1: x1, y1: y1, z1: z1, x2: x2, y2: y2, z2: z2, speed: speed, marker: marker)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func transit(x: Int, y: Int, z: Int) -> Bool {
    return transit(x: x, y: y, z: z, pad1: -2, pad2: -2)
}

public func transit(x: Int, y: Int, z: Int, pad1: Int, pad2: Int) -> Bool {
    let ret = Tello.transit(x: x, y: y, z: z, pad1: pad1, pad2: pad2)
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func transit(x: Int, y: Int, z: Int, speed: UInt, yaw: Int, pad1: Int, pad2: Int) -> Bool {
    let ret = Tello.jump(x: x, y: y, z: z, speed: speed, yaw: yaw, marker1: "m\(pad1)", marker2: "m\(pad2)")
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func land() -> Bool {
    let ret = Tello.land()
    if ret {
        _ = Tello.waitForResponse()
    }
    return ret
}

public func setResponseTimeout(seconds: TimeInterval) {
    TelloManager.responseTimeout = seconds
}
