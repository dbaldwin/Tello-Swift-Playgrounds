//
//  PlaygroundValueExtensions.swift
//  PlaygroundValueExtensions
//
/*
 
 * @version 1.0
 
 * @date Sep 2018
 
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
 * Created by XIAOWEI WANG on 03/09/2018.
 * support@ryzerobotics.com
 *
 
 */

import PlaygroundSupport

extension DroneStatus {
    public func toPlaygroundValue() -> PlaygroundValue {
        let value: PlaygroundValue = PlaygroundValue.dictionary([
            "pitch": .floatingPoint(Double(pitch)),
            "roll":  .floatingPoint(Double(roll)),
            "yaw":   .floatingPoint(Double(yaw)),
            "vgx":   .floatingPoint(Double(vgx)),
            "vgy":   .floatingPoint(Double(vgy)),
            "vgz":   .floatingPoint(Double(vgz)),
            "tof":   .floatingPoint(Double(tof)),
            "h":     .floatingPoint(Double(h)),
            "bat":   .integer(bat),
            "baro":  .floatingPoint(Double(baro)),
            "time":  .floatingPoint(Double(time)),
            "agx":   .floatingPoint(Double(agx)),
            "agy":   .floatingPoint(Double(agy)),
            "agz":   .floatingPoint(Double(agz)),
            "marker": PlaygroundValue.dictionary([
                "id":   .integer(marker.id),
                "x":  .floatingPoint(Double(marker.x)),
                "y":  .floatingPoint(Double(marker.y)),
                "z":   .floatingPoint(Double(marker.z)),
                ]),
            "temp": PlaygroundValue.dictionary([
                "temph":   .integer(temp.temph),
                "templ":   .integer(temp.templ),
                ]),
            "mpry":PlaygroundValue.dictionary([
                "x":  .floatingPoint(Double(mpry.x)),
                "y":  .floatingPoint(Double(mpry.y)),
                "z":   .floatingPoint(Double(mpry.z)),
                ]),
            "sn": .string(sn),
            ])
        return value
    }
    
    public static func fromPlaygroundValue(data: [String : PlaygroundSupport.PlaygroundValue]) -> DroneStatus {
        guard case let .dictionary(markerDict)? = data["marker"],
            case let .dictionary(mpryDict)? = data["mpry"],
            case let .dictionary(tempDict)? = data["temp"] else {
            DroneLog.debug("dictionary not avaiable")
            return DroneStatus.buildNullStatus()
        }
        var pitch: Float = 0.0
        if case let .floatingPoint(value)? = data["pitch"] {
            pitch = Float(value)
        }
        var roll: Float = 0.0
        if case let .floatingPoint(value)? = data["roll"] {
            roll = Float(value)
        }
        var yaw: Float = 0.0
        if case let .floatingPoint(value)? = data["yaw"] {
            yaw = Float(value)
        }
        var vgx: Float = 0.0
        if case let .floatingPoint(value)? = data["vgx"] {
            vgx = Float(value)
        }
        var vgy: Float = 0.0
        if case let .floatingPoint(value)? = data["vgy"] {
            vgy = Float(value)
        }
        var vgz: Float = 0.0
        if case let .floatingPoint(value)? = data["vgz"] {
            vgz = Float(value)
        }
        var tof: Float = 0.0
        if case let .floatingPoint(value)? = data["tof"] {
            tof = Float(value)
        }
        var h: Float = 0.0
        if case let .floatingPoint(value)? = data["h"] {
            h = Float(value)
        }
        var bat: Int = 0
        if case let .integer(value)? = data["bat"] {
            bat = value
        }
        var baro: Float = 0.0
        if case let .floatingPoint(value)? = data["baro"] {
            baro = Float(value)
        }
        var time: Float = 0.0
        if case let .floatingPoint(value)? = data["time"] {
            time = Float(value)
        }
        var agx: Float = 0.0
        if case let .floatingPoint(value)? = data["agx"] {
            agx = Float(value)
        }
        var agy: Float = 0.0
        if case let .floatingPoint(value)? = data["agy"] {
            agy = Float(value)
        }
        var agz: Float = 0.0
        if case let .floatingPoint(value)? = data["agz"] {
            agz = Float(value)
        }
        

        var id: Int = 0
        if case let .integer(value)? = markerDict["id"] {
            id = value
        }
        var x: Float = 0.0
        if case let .floatingPoint(value)? = markerDict["x"] {
            x = Float(value)
        }
        var y: Float = 0.0
        if case let .floatingPoint(value)? = markerDict["y"] {
            y = Float(value)
        }
        var z: Float = 0.0
        if case let .floatingPoint(value)? = markerDict["z"] {
            z = Float(value)
        }
        
        let marker = DroneMarker(id: id, x: x, y: y, z: z)
        
        var temph: Int = 0
        if case let .integer(value)? = tempDict["temph"] {
            temph = value
        }
        var templ: Int = 0
        if case let .integer(value)? = tempDict["templ"] {
            templ = value
        }
        
        let temp = DroneTemperature(templ: templ, temph: temph)
        
        
        var mx: Float = 0.0
        if case let .floatingPoint(value)? = mpryDict["x"] {
            mx = Float(value)
        }
        var my: Float = 0.0
        if case let .floatingPoint(value)? = mpryDict["y"] {
            my = Float(value)
        }
        var mz: Float = 0.0
        if case let .floatingPoint(value)? = mpryDict["z"] {
            mz = Float(value)
        }
        
        var sn: String = ""
        if case let .string(value)? = data["sn"] {
            sn = value
        }
        
        let mpry = (x: mx, y: my, z: mz)
        

        return DroneStatus(marker: marker, mpry: mpry, pitch: pitch, roll: roll, yaw: yaw, vgx: vgx, vgy: vgy, vgz: vgz, temp: temp, tof: tof, h: h, bat: bat, baro: baro, time: time, agx: agx, agy: agy, agz: agz, sn: sn)
    }
    
}

extension CommandFactory.Command {
    
    func toPlaygroundValue(droneId: Int) -> PlaygroundValue {
        let emptyString = PlaygroundValue.string("")
        var value: PlaygroundValue = PlaygroundValue.dictionary([
            "action"  : .string("unknown"),
            "value" : emptyString
            ])
        
        switch self {
        case .command:
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action"  : .string("command"),
                "value" : emptyString
                ])
        case .connectAP(let ssid, let password):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action"   : .string("connectAP"),
                "ssid"     : .string(ssid),
                "password" : .string(password)
                ])
        case .droneStatus(let status):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action"   : .string("droneStatus"),
                "value"    : status.toPlaygroundValue()
                ])
        case .getSN(let sn):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action"  : .string("getSN"),
                "value" : .string(sn)
                ])
        case .takeOff:
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action"  : .string("takeoff"),
                "value" : emptyString
                ])
        case .land:
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action"  : .string("land"),
                "value" : emptyString
                ])
        case .speed(let cms):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action" : .string("speed"),
                "value"  : .integer(Int(cms))
                ])
        case .flyUp(let cm):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action" : .string("flyUp"),
                "value"  : .integer(Int(cm))
                ])
        case .flyDown(let cm):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action" : .string("flyDown"),
                "value"  : .integer(Int(cm))
                ])
        case .flyLeft(let cm):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action" : .string("flyLeft"),
                "value"  : .integer(Int(cm))
                ])
        case .flyRight(let cm):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action" : .string("flyRight"),
                "value"  : .integer(Int(cm))
                ])
        case .flyForward(let cm):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action" : .string("flyForward"),
                "value"  : .integer(Int(cm))
                ])
        case .flyBackward(let cm):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action" : .string("flyBackward"),
                "value"  : .integer(Int(cm))
                ])
        case .turnLeft(let degree):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action" : .string("turnLeft"),
                "value"  : .integer(Int(degree))
                ])
        case .turnRight(let degree):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action" : .string("turnRight"),
                "value"  : .integer(Int(degree))
                ])
        case .flyCurve(let x1, let y1, let z1 , let x2 , let y2 , let z2 , let marker):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action" : .string("flyCurve"),
                "x1"  : .integer(Int(x1)),
                "y1"  : .integer(Int(y1)),
                "z1"  : .integer(Int(z1)),
                "x2"  : .integer(Int(x2)),
                "y2"  : .integer(Int(y2)),
                "z2"  : .integer(Int(z2)),
                "marker"  : .string(marker),
                ])
        case .jump(let x, let y, let z , let speed , let yaw , let marker1 , let marker2):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action" : .string("jump"),
                "x"      : .integer(Int(x)),
                "y"      : .integer(Int(y)),
                "z"      : .integer(Int(z)),
                "speed"  : .integer(Int(speed)),
                "yaw"    : .integer(Int(yaw)),
                "marker1"  : .string(marker1),
                "marker2"  : .string(marker2),
                ])
        case .go(let x, let y, let z , let speed, let marker):
            value = PlaygroundValue.dictionary([
                "droneId"  : .integer(droneId),
                "action" : .string("go"),
                "x"      : .integer(Int(x)),
                "y"      : .integer(Int(y)),
                "z"      : .integer(Int(z)),
                "speed"  : .integer(Int(speed)),
                "marker"  : .string(marker),
                ])
            
        default:
            DroneLog.debug(String(format: "not handle: %@", self.toString()))
            break
        }
        return value
    }
}
