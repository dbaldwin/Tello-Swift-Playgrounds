//
//  Chapter4ViewController.swift
//  Chapter4ViewController
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

import Foundation
import UIKit
import PlaygroundSupport

@objc(Chapter4_1ViewController)
class Chapter4_1ViewController: LiveViewFrameController {
    
    @IBOutlet weak var not_connected: UIImageView!
    @IBOutlet weak var connectedImage: UIImageView!
    func showConnectedImage() {
        UIView.animate(withDuration: 1.0) {
            self.connectedImage.alpha = 1.0
            self.not_connected.alpha = 0
        }
    }
    
    override func handleMessageFromPage(_ message: PlaygroundValue) -> Bool {
        if super.handleMessageFromPage(message) {
            return true
        }

        var handled = true
        guard case let .dictionary(command) = message else {
            DroneLog.debug("dictionary not avaiable")
            handled = false
            return handled
        }
        if case let .string(action)? = command["action"] {
            DroneLog.debug(String(format: "action: %@", action))
            switch action {
            case "connectAP":
                showConnectedImage()
            default:
                handled = false
            }
        }
        return handled
    }
}

@objc(Chapter4_2ViewController)
class Chapter4_2ViewController: LiveViewFrameController {
    @IBOutlet var lbSNs: [UILabel]!
    
    @IBOutlet var flyList: [UIImageView]!
    @IBOutlet var flyTop: [NSLayoutConstraint]!
    
    var flyTopOrigin = [CGFloat]()
    let _upOffset: CGFloat = 110
    let _downOffset: CGFloat = 80
    
    let _takeOffOffset: CGFloat = 87
    
    let _delta: CGFloat = 1.7

    override func viewDidLoad() {
        super.viewDidLoad()
        for top in flyTop {
            flyTopOrigin.append(top.constant)
        }
        #if arch(i386) || arch(x86_64)
        setupDebugButtons()
        #endif
    }
    
    func setupDebugButtons() {
        let viewRect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        let view = UIView(frame: viewRect)
        view.backgroundColor = .red
        self.view.addSubview(view)
        
        
        let font = UIFont.systemFont(ofSize: 11)
        var rect = CGRect(x: 100, y: 100, width: 77, height: 27)
        let btnTakeoff = UIButton(frame: rect)
        btnTakeoff.setTitle("takeOff", for: .normal)
        btnTakeoff.titleLabel?.font = font
        btnTakeoff.backgroundColor = .red
        btnTakeoff.addTarget(self, action: #selector(onButtonTakeOff), for: .touchUpInside)
        self.view.addSubview(btnTakeoff)
        
        rect = CGRect(x: 100, y: 137, width: 77, height: 27)
        let btnFlyUp = UIButton(frame: rect)
        btnFlyUp.setTitle("flyUp", for: .normal)
        btnFlyUp.titleLabel?.font = font
        btnFlyUp.backgroundColor = .red
        btnFlyUp.addTarget(self, action: #selector(onButtonFlyUp), for: .touchUpInside)
        self.view.addSubview(btnFlyUp)
        
        rect = CGRect(x: 100, y: 177, width: 77, height: 27)
        let btnFlyDown = UIButton(frame: rect)
        btnFlyDown.setTitle("flyDown", for: .normal)
        btnFlyDown.titleLabel?.font = font
        btnFlyDown.backgroundColor = .red
        btnFlyDown.addTarget(self, action: #selector(onButtonFlyDown), for: .touchUpInside)
        self.view.addSubview(btnFlyDown)
    }
    
    
    @objc func onButtonTakeOff(_ sender: Any) {
        self.takeOff(droneId: 1)
    }
    
    @objc func onButtonFlyUp(_ sender: Any) {
        self.flyUp(cm: 25, droneId: 1)
    }
    
    @objc func onButtonFlyDown(_ sender: Any) {
        self.flyDown(cm: 25, droneId: 1)
    }

    func takeOff(droneId: Int) {
        _ = UIView.animateAndChain(withDuration: 1.5, delay: 0.0, options: [.beginFromCurrentState], animations: {
            self.flyTop[droneId - 1].constant += -self._takeOffOffset
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func land(droneId: Int) {
        _ = UIView.animateAndChain(withDuration: 1.5, delay: 0.0, options: [.beginFromCurrentState], animations: {
            self.flyTop[droneId - 1].constant = self.flyTopOrigin[droneId - 1]
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func flyUp(cm: Int, droneId: Int) {
        _ = UIView.animateAndChain(withDuration: 1.5, delay: 0.0, options: [.beginFromCurrentState], animations: {
            self.flyTop[droneId - 1].constant += (-self._delta * CGFloat(cm))
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func flyDown(cm: Int, droneId: Int) {
        _ = UIView.animateAndChain(withDuration: 1.5, delay: 0.0, options: [.beginFromCurrentState], animations: {
            self.flyTop[droneId - 1].constant += (self._delta * CGFloat(cm))
            self.view.layoutIfNeeded()

        }, completion: nil)
    }
    
    override func handleMessageFromPage(_ message: PlaygroundValue) -> Bool {
        var handled = true
        if super.handleMessageFromPage(message) {
            return true
        }
        
        guard case let .dictionary(command) = message else {
            DroneLog.debug("dictionary not avaiable")
            handled = false
            return handled
        }
        if case let .string(action)? = command["action"] {
            DroneLog.debug(String(format: "action: %@", action))
            
            guard case let .integer(droneId)? = command["droneId"] else {
                DroneLog.error(String(format: "DroneId not found for action: %@", action))
                return false
            }
            
            flyList[droneId - 1].alpha = 1
            
            DroneLog.debug(String(format: "droneId: %d", droneId))
            
            switch action {
            case "getSN":
                if case let .string(value)? = command["value"] {
                    let sn = String(value.suffix(6))
                    lbSNs[droneId - 1].text = sn
                    DroneLog.debug(String(format: "action: %@, value: %@", action, value))
                } else {
                    DroneLog.error(String(format: "error value : %@", action))
                }
            case "flyUp":
                var up = 0
                if case let .integer(value)? = command["value"] {
                    up = value
                }
                self.flyUp(cm: up, droneId: droneId)
            case "flyDown":
                var down = 0
                if case let .integer(value)? = command["value"] {
                    down = value
                }
                self.flyDown(cm: down, droneId: droneId)

            case "takeoff":
                takeOff(droneId: droneId)
            case "land":
                land(droneId: droneId)
            default:
                break
            }
        }
        return handled
    }
    
    override func onDroneStatusArrived(droneId: Int, status: DroneStatus) {
        super.onDroneStatusArrived(droneId: droneId, status: status)
        if droneId > 0 && droneId < 5 {
            let index = droneId - 1
            flyList[index].alpha = 1
            batteries[index].alpha = 1
            updateBattery(status: status, index: index)
        }
    }
}
@objc(ChapterMultipleDronesViewController)
class ChapterMultipleDronesViewController: LiveViewFrameController {
    @IBOutlet var lbSNs: [UILabel]!

    @IBOutlet var flyList: [UIImageView]!
    @IBOutlet var stayList: [UIImageView]!
    
    @IBOutlet var flyLeft: [NSLayoutConstraint]!
    @IBOutlet var flyTop: [NSLayoutConstraint]!
    
    @IBOutlet var stayLeft: [NSLayoutConstraint]!
    @IBOutlet var stayTop: [NSLayoutConstraint]!
    var _droneObjects = [Int: DroneModelLoop]()

    override public func viewDidLoad() {
        super.viewDidLoad()
        #if arch(i386) || arch(x86_64)
        setupDebugButtons()
        #endif
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DroneLog.debug("viewDidAppear was called")
        buildDroneObjects()
    }
    
    func setupDebugButtons() {
        let viewRect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        let view = UIView(frame: viewRect)
        view.backgroundColor = .red
        self.view.addSubview(view)
        
        
        let font = UIFont.systemFont(ofSize: 11)
        var rect = CGRect(x: 100, y: 100, width: 77, height: 27)
        let btnTakeoff = UIButton(frame: rect)
        btnTakeoff.setTitle("takeOff", for: .normal)
        btnTakeoff.titleLabel?.font = font
        btnTakeoff.backgroundColor = .red
        btnTakeoff.addTarget(self, action: #selector(onButtonTakeOff), for: .touchUpInside)
        self.view.addSubview(btnTakeoff)
        
        rect = CGRect(x: 100, y: 137, width: 77, height: 27)
        let btnMoveToNext = UIButton(frame: rect)
        btnMoveToNext.setTitle("moveToNext", for: .normal)
        btnMoveToNext.titleLabel?.font = font
        btnMoveToNext.backgroundColor = .red
        btnMoveToNext.addTarget(self, action: #selector(onButtonMoveToNext), for: .touchUpInside)
        self.view.addSubview(btnMoveToNext)
    }
    
    @objc func onButtonTakeOff(_ sender: Any) {
        for i in 1...4 {
            let drone = _droneObjects[i]!
            drone.takeOff()
        }
    }

    @objc func onButtonMoveToNext(_ sender: Any) {
        for i in 1...4 {
            let drone = _droneObjects[i]!
            drone.moveToNext()
        }
    }
    
    func testPos(index: Int) {
        let drone = _droneObjects[index]!
        _ = drone.takeOff()
        for i in 0..<10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 + Double(i) * 2.0) {
                _ = drone.moveToNext()
            }
        }
    }

    func buildDroneObjects() {
        var aiPoints: [UIView] = [UIView]()
        var loopPointsList = [[CGPoint]]()
        _droneObjects.removeAll()
        for i in 1..<20 {
            if let view = self.view.viewWithTag(i) {
                aiPoints.append(view)
                view.isHidden = true
            }
        }
        if aiPoints.count > 0 {
            loopPointsList.append(DroneModel.makePoints(views: aiPoints))
            for index in 1..<flyList.count {
                var views : [UIView] = [UIView]()
                for i in index..<index+aiPoints.count {
                    let view = aiPoints[i % aiPoints.count]
                    views.append(view)
                }
                loopPointsList.append(DroneModel.makePoints(views: views))
            }
        }

        for (index, fly) in flyList.enumerated() {
            let stay = stayList[index]
            let top = flyTop[index]
            let left = flyLeft[index]
            let posPoints = loopPointsList[index]
            let droneObject = DroneModelLoop(contentView: self.view, stayAndFlyImage: [stay, fly], topAndLeftCOntraints: [top, left], points: posPoints, currentIndex: index)
            _droneObjects[index+1] = droneObject
        }
    }
    
    override func handleMessageFromPage(_ message: PlaygroundValue) -> Bool {
        var handled = true
        if super.handleMessageFromPage(message) {
            return true
        }

        guard case let .dictionary(command) = message else {
            DroneLog.debug("dictionary not avaiable")
            handled = false
            return handled
        }
        if case let .string(action)? = command["action"] {
            DroneLog.debug(String(format: "action: %@", action))
            
            guard case let .integer(droneId)? = command["droneId"] else {
                DroneLog.error(String(format: "DroneId not found for action: %@", action))
                return false
            }
            guard let drone = _droneObjects[droneId] else {
                DroneLog.error(String(format: "Drone not found for action: %@", action))
                return false
            }
            
            DroneLog.debug(String(format: "droneId: %d", droneId))
            
            switch action {
            case "getSN":
                if case let .string(value)? = command["value"] {
                    let sn = String(value.suffix(6))
                    lbSNs[droneId - 1].text = sn
                    DroneLog.debug(String(format: "action: %@, value: %@", action, value))
                } else {
                    DroneLog.error(String(format: "error value : %@", action))
                }
            case "takeoff":
                _ = drone.takeOff()
            case "land":
                _ = drone.land()
            case "turnLeft":
                var degree = 360
                if case let .integer(value)? = command["value"] {
                    degree = value
                }
                _ = drone.turnLeft(degree: degree)
                
            case "turnRight":
                var degree = 360
                if case let .integer(value)? = command["value"] {
                    degree = value
                }
                _ = drone.turnRight(degree: degree)
            case "flyUp":
                _ = drone.flyUp()
            case "flyDown":
                _ = drone.flyDown()
            case "flyCurve":
                DroneLog.error(String(format: "flyCurve can not be handled"))
                // _ = drone.flyCurve()
            case "flyForward", "flyBackward":
                _ = drone.moveToNext()
            case "flyLeft":
                _ = drone.moveToNext()
            case "flyRight":
                _ = drone.moveToNext()
            case "go":
                _ = drone.moveToNext()
            case "jump":
                _ = drone.moveToNext()
            default:
                DroneLog.error(String(format: "`%@` can not be handled", action))
                handled = false
            }
        }
        return handled
    }
    
    override func onDroneStatusArrived(droneId: Int, status: DroneStatus) {
        super.onDroneStatusArrived(droneId: droneId, status: status)
        if droneId > 0 && droneId < 5 {
            let index = droneId - 1
            flyList[index].alpha = 1
        }
    }
}

@objc(Chapter4_3ViewController)
class Chapter4_3ViewController: Chapter4_2ViewController {
}

@objc(Chapter4_4ViewController)
class Chapter4_4ViewController: ChapterMultipleDronesViewController {
}

@objc(Chapter4_5ViewController)
class Chapter4_5ViewController: LiveViewBaseController {
}
