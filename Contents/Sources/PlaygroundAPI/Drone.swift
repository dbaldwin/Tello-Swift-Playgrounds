//
//  Drone.swift
//  Drone
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

public class Drone {
    var _assessor: Assessor? = nil
    let _batteryLimit = 15
    
    private var _executeQueue: DispatchQueue!
    private var _responseSemaphore: DispatchSemaphore!
    
    internal var assessor: Assessor? {
        get { return _assessor }
        set { _assessor = newValue }
    }

    init(dronePuppet: DronePuppet) {
        self._dronePuppet = dronePuppet
        initialize()
    }

    convenience init() {
        self.init(dronePuppet: DronePuppet())
    }

    func initialize() {
        _executeQueue = DispatchQueue(label: self._dronePuppet.key + "DroneExecuteQueue")
        _responseSemaphore = DispatchSemaphore(value: 0)
    }

    private var _dronePuppet: DronePuppet

    public var puppet: DronePuppet {
        get { return _dronePuppet }
    }

    public var ready : Bool {
        get {
            return _dronePuppet.id > 0
        }
    }
    
    public var canFly : Bool {
        return ready && !isLowBattery
    }
    
    public var isLowBattery: Bool {
        if let status = _dronePuppet.status {
            return status.bat <= _batteryLimit
        }
        return false
    }

    public var statusReady: Bool {
        return _dronePuppet.status != nil
    }
    
    public var status: DroneStatus? {
        return _dronePuppet.status
    }
    
    public func recordAction(action: Assessor.Action) {
        if let assessor = self._assessor{
            assessor.add(action: action)
        }
    }
    
    func notifyResponse(response: String) {
        if self.ready {
            DroneLog.debug("before _responseSemaphore.signal: \(response)")
            puppet.notifyResponse(response: response)
            self._responseSemaphore.signal()
            DroneLog.debug("after _responseSemaphore.signal: \(response)")
        }
    }
    
    public func waitForResponse(seconds: Int = 15) -> Bool {
        DroneLog.debug("before wait \(seconds) \(_responseSemaphore.debugDescription)")
        let result = _responseSemaphore.wait(timeout: .now() + 15)
        let ret    =  result  == DispatchTimeoutResult.success
        DroneLog.debug(String(format: "after wait: %@", ret ? "true" : "false"))
        return ret
    }

    internal func canQueueCommand(commandString: String, command: CommandFactory.Command) -> Bool {
        if self.canFly {
            puppet.queueCommand(commandString: commandString, command: command)
        }
        return self.canFly
    }

    internal func sync(group: DispatchGroup, seconds: UInt, timeout: TimeInterval = 10) {
        if canFly {
            puppet.sync(group: group, seconds: seconds, timeout: timeout)
        }
    }

    /// Get current Speed (1-100 cm/s).
    public func getSpeed() -> UInt {
        var speed: UInt = 0
        if self.ready {
            speed = _dronePuppet.speed
        }
        return speed
    }

    /// Get current battery( 0-100% ).
    public func getBattery() -> Int {
        if self.ready, let status = _dronePuppet.status {
            return status.bat
        }
        return 0
    }

    /// Get flight duration in seconds.
    public func getTime() -> Int {
        if self.ready, let status = _dronePuppet.status {
            return Int(status.time)
        }
        return 0
    }

    public func command() -> Bool {
        var ret = false
        if self.ready {
            puppet.queueCommand(commandString: "command", command: .command)
            ret = true
        }
        return ret
    }
    
    public func connectAP(ssid: String, password: String) -> Bool {
        var ret = false
        if self.ready {
            puppet.queueCommand(commandString: String(format: "ap %@ %@", ssid, password), command: .connectAP(ssid: ssid, password: password))
            ret = true
            recordAction(action: .connectAP(ssid: ssid, password: password))
        }
        return ret
    }

    public func getSN() -> Bool {
        var ret = false
        if self.ready {
            puppet.queueCommand(commandString: String(format: "sn?"), command: .getSN(sn: "no-sn"))
            ret = true
        }
        return ret
    }
    
    @discardableResult
    public func mon() -> Bool {
        var ret = false
        if self.ready {
            let commandString = CommandFactory.mon()
            puppet.queueCommand(commandString: commandString, command: .mon)
            ret = true
        }
        return ret
    }
    
    @discardableResult
    public func mdirection(direction: Int) -> Bool {
        var ret = false
        if self.ready {
            let commandString = CommandFactory.mdirection(direction: direction)
            puppet.queueCommand(commandString: commandString, command: .mdirection(direction: direction))
            ret = true
        }
        return ret
    }
    
    public func setSpeed(cms: UInt) -> Bool {
        var ret = false
        if self.ready {
            let commandString = CommandFactory.setSpeed(cms: cms)
            puppet.queueCommand(commandString: commandString, command: .setSpeed)
            puppet.speed = cms
            ret = true
        }
        if ret {
            recordAction(action: .setSpeed(cms: cms))
        }
        return ret
    }
    
    public func land() -> Bool {
        let commandString = CommandFactory.land()
        let ret = canQueueCommand(commandString: commandString, command: .land)
        if ret {
            recordAction(action: .land)
        }
        return ret
    }
    
    /// Take off. This function make the drone fly and wait at about 1m height.
    public func takeOff() -> Bool {
        let commandString = CommandFactory.takeoff()
        let ret = canQueueCommand(commandString: commandString, command: .takeOff)
        if ret {
            recordAction(action: .takeOff)
        }
        return ret
    }
    
    /// Up by centimeters. cm should be between 20 and 500
    @discardableResult
    public func flyUp(cm: UInt) -> Bool {
        var ret = false
        do {
            let (cmdString, command) = try CommandFactory.flyUp(cm: cm)
            ret = canQueueCommand(commandString: cmdString, command: command)
            if ret {
                recordAction(action: .flyUp(cm: cm))
            }
        } catch {
        }
        return ret
    }
    
    /// Down by centimeters. cm should be between 20 and 500
    @discardableResult
    public func flyDown(cm: UInt) -> Bool {
        var ret = false
        do {
            let (cmdString, command) = try CommandFactory.flyDown(cm: cm)
            ret = canQueueCommand(commandString: cmdString, command: command)
            if ret {
                recordAction(action: .flyDown(cm: cm))
            }
        } catch {
        }
        return ret
    }

    /// Left by centimeters. cm should be between 20 and 500
    public func flyLeft(cm: UInt) -> Bool {
        var ret = false
        do {
            let (cmdString, command) = try CommandFactory.flyLeft(cm: cm)
            ret = canQueueCommand(commandString: cmdString, command: command)
            if ret {
                recordAction(action: .flyLeft(cm: cm))
            }
        } catch {
        }
        return ret
    }

    public func flyRight(cm: UInt) -> Bool {
        var ret = false
        do {
            let (cmdString, command) = try CommandFactory.flyRight(cm: cm)
            ret = canQueueCommand(commandString: cmdString, command: command)
            if ret {
                recordAction(action: .flyRight(cm: cm))
            }
        } catch {
        }
        
        return ret
    }

    public func flyForward(cm: UInt) -> Bool {
        var ret = false
        do {
            let (cmdString, command) = try CommandFactory.flyForward(cm: cm)
            ret = canQueueCommand(commandString: cmdString, command: command)
            if ret {
                recordAction(action: .flyForward(cm: cm))
            }
        } catch {
        }
        return ret
    }

    public func flyBackward(cm: UInt) -> Bool {
        var ret = false

            do {
                let (cmdString, command) = try CommandFactory.flyBackward(cm: cm)
                ret = canQueueCommand(commandString: cmdString, command: command)
                if ret {
                    recordAction(action: .flyBackward(cm: cm))
                }
            } catch {
            }

        return ret
    }

    public func turnLeft(degree: Int) -> Bool {
        var ret = false
        do {
            let (cmdString, command) = try CommandFactory.turnLeft(degree: degree)
            ret = canQueueCommand(commandString: cmdString, command: command)
            if ret {
                recordAction(action: .turnLeft(degree: degree))
            }
        } catch {
        }
        return ret
    }

    public func turnRight(degree: Int) -> Bool {
        var ret = false
        do {
            let (cmdString, command) = try CommandFactory.turnRight(degree: degree)
            ret = canQueueCommand(commandString: cmdString, command: command)
            if ret {
                recordAction(action: .turnRight(degree: degree))
            }
        } catch {
        }
        return ret
    }
    
    @discardableResult
    internal func transit(x: Int, y: Int, z: Int) -> Bool {
        return transit(x: x, y: y, z: z, pad1: -2, pad2: -2)
    }

    @discardableResult
    public func transit(x: Int, y: Int, z: Int, pad1: Int, pad2: Int) -> Bool {
        var ret = false
        if self.ready {
            recordAction(action: .transit(x: x, y: y, z: z, pad1: pad1, pad2: pad2))
            let speed = getSpeed()
            let m1 = String(format: "m%d", pad1)
            let m2 = String(format: "m%d", pad2)
            ret = jump(x: x, y: y, z: z, speed: speed, yaw: 0, marker1: m1, marker2: m2)
        }
        return ret
    }

    public func flyLine(x: Int, y: Int, z: Int, pad: Int) -> Bool {
        var ret = false
        if self.ready {
            let speed = getSpeed()
            Tello.recordAction(action: .flyLine(x: x, y: y, z: z, pad: pad))
            ret = go(x: x, y: y, z: z, speed: speed, marker: "m\(pad)")
        }
        return ret
    }
    // Low-layer APIs

    public func go(x: Int, y: Int, z: Int, speed: UInt, marker: String) -> Bool {
        let commandString = CommandFactory.go(x: x, y: y, z: z, speed: speed, marker: marker)
        let ret = canQueueCommand(commandString: commandString, command: .go(x: x, y: y, z: z, speed: speed, marker: marker))
        return ret
    }

    public func go(x: Int, y: Int, z: Int, speed: UInt) -> Bool {
        return go(x: x, y: y, z: z, speed: speed, marker: "")
    }

    public func rc(ch0: UInt, ch1: UInt, ch2: UInt, ch4: UInt) -> Bool {
        let commandString = CommandFactory.rc(ch0: ch0, ch1: ch1, ch2: ch2, ch4: ch4)
        let ret = canQueueCommand(commandString: commandString, command: .rc)
        return ret
    }

    public func curve(x1: Int, y1: Int, z1: Int, x2: Int,y2: Int, z2: Int, speed: UInt, marker: String) -> Bool {
        let commandString = CommandFactory.curve(x1: x1, y1: y1, z1: z1, x2: x2, y2: y2, z2: z2, speed: speed, marker: marker)
        let ret = canQueueCommand(commandString: commandString, command: .flyCurve(x1: x1, y1: y1, z1: z1, x2: x2, y2: y2, z2: z2, marker: marker))
        return ret
    }

    public func jump(x: Int, y: Int, z: Int, speed: UInt, yaw: Int, marker1: String, marker2: String) -> Bool {
        let commandString = CommandFactory.jump(x: x, y: y, z: z, speed: speed, yaw: 0, marker1: marker1, marker2: marker2)
        let ret = canQueueCommand(commandString: commandString, command: .jump(x: x, y: y, z: z, speed: speed, yaw: yaw, marker1: marker1, marker2: marker2) )
        return ret
    }
}
