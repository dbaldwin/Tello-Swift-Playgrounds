//
//  LiveViewFrameController.swift
//  LiveViewFrameController
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

@objc(LiveViewFrameController)
public class LiveViewFrameController: UIViewController, PlaygroundLiveViewSafeAreaContainer {
    fileprivate (set) var liveViewConnectionOpened = false
    
    @IBOutlet weak var lbVersion: UILabel!
    @IBOutlet var batteries: [UIImageView]!
    let _tempLimit = 80
    

    var _droneStatus = [Int: DroneStatus]()

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        setupVersionLabel()
    }
    
    func resetLiveView() {
        for battery in batteries {
            battery.image = UIImage(named: "battery_ic_11")
        }
        
        _droneStatus = [Int: DroneStatus]()
    }

    weak var chain: EAAnimationFuture?

    func setupVersionLabel() {
        #if arch(i386) || arch(x86_64)
        lbVersion.text = "Build: \(getBuild()) Git: \(getGitHash())"
        #else
        lbVersion.text = ""
        #endif
    }

    func updateBattery( status: DroneStatus, index: Int ) {
        let battery = status.bat
        switch battery {
        case 1...15:
            let imageName = status.temp.templ > _tempLimit ?  "battery_ic_42" :  "battery_ic_41"
            batteries[index].image = UIImage(named: imageName)
        case 16...43:
            let imageName = status.temp.templ > _tempLimit ?  "battery_ic_32" :  "battery_ic_31"
            batteries[index].image = UIImage(named: imageName)
        case 44...71:
            let imageName = status.temp.templ > _tempLimit ?  "battery_ic_22" :  "battery_ic_21"
            batteries[index].image = UIImage(named: imageName)
        case 72...100:
            let imageName = status.temp.templ > _tempLimit ?  "battery_ic_12" :  "battery_ic_11"
            batteries[index].image = UIImage(named: imageName)
        default:
            DroneLog.error("updateBattery default")
        }
    }

    func onDroneStatusArrived(droneId: Int, status: DroneStatus) {
        // DroneLog.debug(String(format: "droneId: %d, bat: %d", droneId, status.bat))
        _droneStatus[droneId] = status
        if droneId > 0 && droneId < 5 {
            let index = droneId - 1
            batteries[index].alpha = 1
            updateBattery(status: status, index: index)
        }
    }
    
    func processUnhanldedCases(_ message: PlaygroundValue) -> Bool {
        return false
    }

    func handleMessageFromPage(_ message: PlaygroundValue) -> Bool {
        var handled = true
        guard case let .dictionary(command) = message else {
            DroneLog.debug("dictionary not avaiable")
            handled = false
            return handled
        }

        if case let .string(action)? = command["action"] {
            // DroneLog.debug(String(format: "action: %@", action))
            switch action {
            case "droneStatus":
                if case let .dictionary(value)? = command["value"],
                    case let .integer(droneId)? = command["droneId"]{
                    let status = DroneStatus.fromPlaygroundValue(data: value)
                    onDroneStatusArrived(droneId: droneId, status: status)
                    // DroneLog.debug(String(format: "logDroneStatus: %d", droneId))
                } else {
                    DroneLog.error(String(format: "no logDroneStatus: %d"))
                }
            case "connected", "command":
                #if arch(i386) || arch(x86_64)
                if case let .string(value)? = command["value"] {
                    lbVersion.text = value
                } else {
                    lbVersion.text = "Connected"
                }
                #endif
            default:
                handled = processUnhanldedCases(message)
            }
        } else {
            handled = false
            DroneLog.debug("action not avaiable")
        }
        return handled
    }

}

extension LiveViewFrameController: PlaygroundLiveViewMessageHandler {
    // Implement this method to be notified when the live view message connection is opened.
    // The connection will be opened when the process running Contents.swift starts running and listening for messages.
    final public func liveViewMessageConnectionOpened() {
        liveViewConnectionOpened = true
        resetLiveView()
    }

    // Implement this method to be notified when the live view message connection is closed.
    // The connection will be closed when the process running Contents.swift exits and is no longer listening for messages.
    // This happens when the user's code naturally finishes running, if the user presses Stop, or if there is a crash.
    final public func liveViewMessageConnectionClosed() {
        liveViewConnectionOpened = false
    }
    
    // Implement this method to receive messages sent from the process running Contents.swift.
    // This method is *required* by the PlaygroundLiveViewMessageHandler protocol.
    // Use this method to decode any messages sent as PlaygroundValue values and respond accordingly.
    public func receive(_ message: PlaygroundValue) {
        _ = handleMessageFromPage(message)
    }

    func send(event: String) {
        if liveViewConnectionOpened {
            //send(event: event.marshal())
        }
    }
}
