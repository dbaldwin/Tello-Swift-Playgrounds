//
//  CommandFactory.swift
//  CommandFactory
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

import PlaygroundSupport

public enum DroneCommanderError: Error {
    case ConnectError(String)
    case OutOfRange(String)
}

public class CommandFactory {
    public enum Command {
        case connectAP(ssid: String, password: String)
        case takeOff
        case land
        case droneStatus( status: DroneStatus)
        
        case speed(cms: UInt)
        case flyUp(cm: UInt)
        case flyDown(cm: UInt)
        case flyLeft(cm: UInt)
        case flyRight(cm: UInt)
        case flyForward(cm: UInt)
        case flyBackward(cm: UInt)
        case turnLeft(degree: Int)
        case turnRight(degree: Int)
        
        case flyCurve(x1: Int, y1: Int, z1: Int, x2: Int,y2: Int, z2: Int, marker: String)
        case jump(x: Int, y: Int, z: Int, speed: UInt, yaw: Int, marker1: String, marker2: String)
        case go(x: Int, y: Int, z: Int, speed: UInt, marker: String)
        
        case null
        case sync(seconds: UInt)
        case mon
        case mdirection(direction: Int)
        case command
        case getTime
        case getSpeed
        case setSpeed
        case getBattery
        case getSN(sn: String)
        case getHeight(value: Double)

        case rc
        
        func toString() -> String {
            var string = "unknown"
            switch self {
            case .command:
                string = "command"
            case .connectAP(let ssid, let password):
                string = String(format: "ap %@ %@", ssid, password)
            case .takeOff:
                string = "takeOff"
            case .land:
                string = "land"
            case .droneStatus( _):
                string = "get drone status: "
            case .getSN(let sn):
                string = String(format: "sn %@", sn)
            case .speed(let cms):
                string = String(format: "speed %d", cms)
            case .flyUp(let cm):
                string = String(format: "flyUp %d", cm)
            case .flyDown(let cm):
                string = String(format: "flyDown %d", cm)
            case .flyLeft(let cm):
                string = String(format: "flyLeft %d", cm)
            case .flyRight(let cm):
                string = String(format: "flyRight %d", cm)
            case .flyForward(let cm):
                string = String(format: "flyForward %d", cm)
            case .flyBackward(let cm):
                string = String(format: "flyBackward %d", cm)
            case .turnLeft(let degree):
                string = String(format: "turnLeft %d", degree)
            case .turnRight(let degree):
                string = String(format: "turnRight %d", degree)
            case .flyCurve(let x1, let y1, let z1 , let x2 , let y2 , let z2 , let marker):
                string = String(format: "flyCurve %d %d %d %d %d %d %@", x1, y1, z1, x2, y2, z2, marker)
            case .go(let x, let y, let z, let speed, let marker):
                string = String(format: "go %d %d %d %d %@", x, y, z, speed, marker)
            case .sync(let seconds):
                string = String(format: "sync %d", seconds)
            case .mon:
                string = String(format: "mon")
            case .mdirection(let mdirection):
                string = String(format: "mdirection %d", mdirection)
            case .getHeight(let value):
                string = String(format: "getHeight %02f", value)
            default:
                break
            }
            return string
        }
    }

    public class func mon() -> String {
        return "mon"
    }
    
    public class func mdirection(direction: Int) -> String {
        return "mdirection \(direction)"
    }
    
    /// Get current Speed (1-100 cm/s).
    public class func getSN() -> String {
        return  "sn?"
    }

    /// Get current Speed (1-100 cm/s).
    public class func getSpeed() -> String {
        return  "speed?"
    }
    
    /// Get current battery( 0-100% ).
    public class func getBattery() -> String {
        return "battery?"
    }
    
    /// Get flight duration.
    public class func getTime() -> String {
        return "time?"
    }
    
    /// Set current Speed (1-100 cm/s).
    public class func setSpeed(cms: UInt) -> String {
        return "speed \(cms)"
    }
    
    /// Take off. This function make the drone fly and wait at about 1m height.
    public class func takeoff() -> String {
        return "takeoff"
    }
    
    /// Land. This function make the drone land at its current position
    public class func land() -> String {
        return "land"
    }
    
    /// Up by centimeters. cm should be between 20 and 500
    public class func flyUp(cm: UInt) throws -> (String, Command) {
        return (try executeMove(direction: .up, cm: cm), .flyUp(cm: cm))
    }
    
    /// Down by centimeters. cm should be between 20 and 500
    public class func flyDown(cm: UInt) throws ->  (String, Command) {
        return (try executeMove(direction: .down, cm: cm), .flyDown(cm: cm))
    }
    
    /// Left by centimeters. cm should be between 20 and 500
    public class func flyLeft(cm: UInt) throws ->  (String, Command) {
        return (try executeMove(direction: .left, cm: cm), .flyLeft(cm: cm))
    }
    
    /// Right by centimeters. cm should be between 20 and 500
    public class func flyRight(cm: UInt) throws ->  (String, Command) {
        return (try executeMove(direction: .right, cm: cm), .flyRight(cm: cm))
    }
    
    /// Forward by centimeters. cm should be between 20 and 500
    public class func flyForward(cm: UInt) throws ->  (String, Command) {
        return (try executeMove(direction: .forward, cm: cm), .flyForward(cm: cm))
    }
    
    /// Backward by centimeters. cm should be between 20 and 500
    public class func flyBackward(cm: UInt) throws ->  (String, Command) {
        return (try executeMove(direction: .back, cm: cm), .flyBackward(cm: cm))
    }
    
    /// Move in a single direction at the specified distance.
    ///
    /// - Parameters:
    ///   - direction: direction to move
    ///   - cm: distance to move
    public class func executeMove(direction: MoveDirection, cm: UInt) throws -> String {
        guard cm >= 1 && cm <= 500 else {
            throw DroneCommanderError.OutOfRange("\(cm) is out of range(20-500)")
        }
        let cmd = direction.rawValue
        let fullCmd = String(format: "%@ %d", cmd, cm)
        return fullCmd
    }
    
    /// Turn left by angle.
    public class func turnLeft(degree: Int) throws -> (String, Command) {
        return (try executeTurn(direction: .left, degree: degree), .turnLeft(degree: degree))
    }
    
    /// Turn right by angle.
    public class func turnRight(degree: Int) throws -> (String, Command) {
        return (try executeTurn(direction: .right, degree: degree), .turnRight(degree: degree))
    }

    /// Turn direction
    ///
    /// - Parameters:
    ///   - direction: direction to turn
    ///   - angle:     angle to turn in degrees (1 to 3600 degrees)
    public class func executeTurn(direction: TurnDirection, degree: Int) throws -> String {
        guard degree >= 1 && degree <= 3600 else {
            throw DroneCommanderError.OutOfRange("\(degree) is out of range(1-3600)")
        }
        let cmd = direction.rawValue
        let fullCmd = String(format: "%@ %d", cmd, degree)
        return fullCmd
    }
    
    public class func curve(x1: Int, y1: Int, z1: Int, x2: Int, y2: Int, z2: Int, speed: UInt, marker: String = "") -> String {
        let cmd = "curve \(x1) \(y1) \(z1) \(x2) \(y2) \(z2) \(speed) \(marker)".trimmingCharacters(in: .whitespaces)
        return cmd
    }

    public class func rc(ch0: UInt, ch1: UInt, ch2: UInt, ch4: UInt) -> String {
        let cmd = "rc \(ch0) \(ch1) \(ch2) \(ch4)"
        return cmd
    }

    public class func go(x: Int, y: Int, z: Int, speed: UInt, marker: String) -> String {
        let cmd = "go \(x) \(y) \(z) \(speed) \(marker)".trimmingCharacters(in: .whitespaces)
        return cmd
    }

    public class func jump(x: Int, y: Int, z: Int, speed: UInt, yaw: Int, marker1: String, marker2: String) -> String {
        let cmd = "jump \(x) \(y) \(z) \(speed) \(yaw) \(marker1) \(marker2)".trimmingCharacters(in: .whitespaces)
        return cmd
    }

}
