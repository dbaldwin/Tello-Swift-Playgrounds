//
//  DroneStatus.swift
//  DroneStatus
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

public struct DroneMarker {
    public var id: Int
    public var x: Float
    public var y: Float
    public var z: Float
    public static func build(data: [String]) -> DroneMarker {
        let id = Int(data[0])!
        let x = Float(data[1])!
        let y = Float(data[2])!
        let z = Float(data[3])!
        return DroneMarker(id: id, x: x, y: y, z: z)
    }
}

public struct DroneTemperature {
    public var templ: Int
    public var temph: Int
    public static func build(matchedData: [String]) -> DroneTemperature {
        let temp1 = Int(matchedData[0])!
        let temp2 = Int(matchedData[1])!
        return DroneTemperature(templ: temp1, temph: temp2)
    }
}

public struct DroneStatus {
    public var marker: DroneMarker
    public var mpry:  (x: Float, y: Float, z: Float)
    public var pitch: Float
    public var roll:  Float
    public var yaw:   Float
    public var vgx:   Float
    public var vgy:   Float
    public var vgz:   Float
    public var temp:  DroneTemperature
    public var tof:   Float
    public var h:     Float
    public var bat:   Int
    public var baro:  Float
    
    public var time:  Float
    public var agx:   Float
    public var agy:   Float
    public var agz:   Float
    
    public var sn:    String
    
    public var isValid: Bool {
        return bat > 0
    }
    
    public static func buildNullStatus() -> DroneStatus {
        return DroneStatus(
            marker: DroneMarker(id: 0, x: 0, y: 0, z: 0), mpry: (x: 0, y: 0, z: 0), pitch: 0, roll: 0, yaw: 0,
            vgx: 0, vgy: 0, vgz: 0, temp: DroneTemperature(templ: 0, temph: 0), tof: 0, h: 0, bat: 0, baro: 0, time: 0,
            agx: 0, agy: 0, agz: 0, sn: ""
        )
    }
    
    public static func build_mpry(mpryData: [String]) -> (x: Float, y: Float, z: Float) {
        return (x: Float(mpryData[0])!, y: Float(mpryData[0])!, z: Float(mpryData[0])!)
    }
    
    public static func build(matchedData: [String]) -> DroneStatus {
        var copy = matchedData
        
        let markerData = [copy.removeFirst(), copy.removeFirst(), copy.removeFirst(), copy.removeFirst()]
        let marker = DroneMarker.build(data: markerData)
        
        let mpryData = [copy.removeFirst(), copy.removeFirst(), copy.removeFirst()]
        let mpry   = build_mpry(mpryData: mpryData)
        
        let pitch: Float = Float(copy.removeFirst())!
        let roll: Float = Float(copy.removeFirst())!
        let yaw: Float = Float(copy.removeFirst())!
        
        let vgx: Float = Float(copy.removeFirst())!
        let vgy: Float = Float(copy.removeFirst())!
        let vgz: Float = Float(copy.removeFirst())!
        
        let temperData = [copy.removeFirst(), copy.removeFirst()]
        let temp: DroneTemperature = DroneTemperature.build(matchedData: temperData)
        
        let tof: Float = Float(copy.removeFirst())!
        let h: Float = Float(copy.removeFirst())!
        let bat: Int = Int(copy.removeFirst())!
        let baro: Float = Float(copy.removeFirst())!
        
        let time: Float = Float(copy.removeFirst())!
        let agx: Float = Float(copy.removeFirst())!
        let agy: Float = Float(copy.removeFirst())!
        let agz: Float = Float(copy.removeFirst())!

        return DroneStatus(
            marker: marker, mpry: mpry, pitch: pitch, roll: roll, yaw: yaw,
            vgx: vgx, vgy: vgy, vgz: vgz, temp: temp, tof: tof, h: h, bat: bat, baro: baro, time: time,
            agx: agx, agy: agy, agz: agz, sn: ""
        )
    }

    public static func buildPattern() -> String {
        let floatRE = "([-\\d.]+)"
        let idRE = "([-0-9]+)"
        let mpry  = "([-\\d.nan]+)"
        let rePattern = "mid:\(idRE);x:\(floatRE);y:\(floatRE);z:\(floatRE);mpry:\(mpry),\(floatRE),\(floatRE);pitch:\(floatRE);roll:\(floatRE);yaw:\(floatRE);vgx:\(floatRE);vgy:\(floatRE);vgz:\(floatRE);templ:\(floatRE);temph:\(floatRE);tof:\(floatRE);h:\(floatRE);bat:\(floatRE);baro:\(floatRE);time:\(floatRE);agx:\(floatRE);agy:\(floatRE);agz:\(floatRE);"
        return rePattern
    }
}
