//
//  PlaygroundSetup.swift
//  PlaygroundSetup
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

import UIKit
import PlaygroundSupport

private var _manager: DroneManager? = nil
public var Tello: Drone!
private var _debugDrone: String? = nil
public var TelloManager: DroneManager {
    get {
        if _manager == nil {
            _manager = DroneManager()
            _manager?._delegate = DroneCommandResponse()
        }
        return _manager!
    }
}

public func setDebugDrone(ipAddress: String ) {
    _debugDrone = ipAddress
}

public func scanOne() -> Int {
    if let tmp = _manager {
        tmp.close()
        _manager = nil
    }
    
    let count = TelloManager.scan(ipAddress: _debugDrone ?? "192.168.10.1")
    if count > 0 {
        Tello = TelloManager.drones.first!
        while !Tello.statusReady {
            delay(milliseconds: 500)
        }
    } else {
        Tello = Drone(dronePuppet: DronePuppet())
    }
    return count
}

internal func scan(number: Int, timeout: TimeInterval = 10) -> Int {
    if let tmp = _manager {
        tmp.close()
        _manager = nil
    }
    
    let count = TelloManager.scan(number: number, timeout: timeout)
    _ = TelloManager.drones.getSN()
    return count
}

public func _setup(controllerName: String) {
    initLogger(level: .debug)
    PlaygroundPage.current.liveView = instantiateLiveView(controllerName: controllerName)
}

public func _setup(storyboardName: String) {
    initLogger(level: .debug)
    PlaygroundPage.current.liveView = instantiateLiveView(storyboardName: storyboardName)
}

public func _setupOneDroneEnv(mon: Bool = false) {
    initLogger(level: .debug)
    //setDebugDrone(ipAddress: "192.168.31.11")
    if scanOne() > 0 {
        _sendToView(value: .dictionary([
            "action":  PlaygroundValue.string("connected"),
            "value" :  PlaygroundValue.string("Connected to Drone")
            ]))
    } else {
        _sendToView(value: .dictionary([
            "action":  PlaygroundValue.string("status"),
            "value" :  PlaygroundValue.string("No drones found")
            ]))
    }
    PlaygroundPage.current.needsIndefiniteExecution = true
}

public func _sendToView(value: PlaygroundValue) {
    if let handler = PlaygroundPage.current.liveView as? PlaygroundLiveViewMessageHandler {
        handler.send(value)
    }
}

public func _setupMultipleDronesEnv() {
    initLogger(level: .debug)
    PlaygroundPage.current.needsIndefiniteExecution = true
}

public func _cleanOneDroneEnv() {
    TelloManager.close()
    PlaygroundPage.current.needsIndefiniteExecution = false
}

public func _cleanMultipleDroneEnv() {
    TelloManager.sync(seconds: 10)
    TelloManager.close()
    PlaygroundPage.current.needsIndefiniteExecution = false
}
