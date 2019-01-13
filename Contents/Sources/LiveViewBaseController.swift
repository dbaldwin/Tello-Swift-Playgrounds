//
//  LiveViewBaseController.swift
//  LiveViewBaseController
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

@objc(LiveViewBaseController)
public class LiveViewBaseController: LiveViewFrameController {
    
    @IBOutlet weak var imageFlyTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageFlyLeftConstraint: NSLayoutConstraint!
    
    var backgroundImage: UIImageView!

    @IBOutlet weak var imageStay: UIImageView!
    @IBOutlet weak var imageFly: UIImageView!
    
    var imageStayTop: CGFloat!
    var imageStayLeft: CGFloat!
    
    var animation: EAAnimationFuture!
    var scaledTransform = CGAffineTransform.identity
    var scaledAndRotatedTransform = CGAffineTransform.identity
    
    
    var originTopConstant: CGFloat = 0
    var originLeftConstant: CGFloat = 0


    var _droneObject: DroneModel!
    let _defaultDroneId = 1
    
    // debug Buttons
    var btnTakeoff: UIButton!
    var btnMoveToNext: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        #if arch(i386) || arch(x86_64)
        setupDebugButtons()
        #endif
        originTopConstant = imageFlyTopConstraint.constant
        originLeftConstant = imageFlyLeftConstraint.constant
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if arch(i386) || arch(x86_64)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.buildDroneObjects()
        }
        #endif
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        resetLiveView()
    }
    
    override func resetLiveView() {
        super.resetLiveView()
        if _droneObject != nil {
            _droneObject.reset()
        }
        self.imageFlyTopConstraint.constant = self.originTopConstant
        self.imageFlyLeftConstraint.constant = self.originLeftConstant
        self.buildDroneObjects()
    }

    @objc func onButtonTakeOff(_ sender: Any) {
        let takeOff = CommandFactory.Command.takeOff.toPlaygroundValue(droneId: 1)
        _ = self.handleMessageFromPage(takeOff)
    }

    @objc func onButtonMoveToNext(_ sender: Any) {
        self.moveToNext()
    }
    
    @objc func onButtonFlyDown(_ sender: Any) {
        self.flyDown()
    }

    @objc func onButtonFlyCurve(_ sender: Any) {
        self.flyCurve()
    }
    
    @objc func onButtonTurnLeft(_ sender: Any) {
        self.turnLeft(degree: 270)
    }

    
    func setupDebugButtons() {
        let viewRect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        let view = UIView(frame: viewRect)
        view.backgroundColor = .red
        self.view.addSubview(view)
        
        
        let font = UIFont.systemFont(ofSize: 11)
        var rect = CGRect(x: 100, y: 100, width: 77, height: 27)
        btnTakeoff = UIButton(frame: rect)
        btnTakeoff.setTitle("takeOff", for: .normal)
        btnTakeoff.titleLabel?.font = font
        btnTakeoff.backgroundColor = .red
        btnTakeoff.addTarget(self, action: #selector(onButtonTakeOff), for: .touchUpInside)
        self.view.addSubview(btnTakeoff)

        rect = CGRect(x: 100, y: 137, width: 77, height: 27)
        btnMoveToNext = UIButton(frame: rect)
        btnMoveToNext.setTitle("moveToNext", for: .normal)
        btnMoveToNext.titleLabel?.font = font
        btnMoveToNext.backgroundColor = .red
        btnMoveToNext.addTarget(self, action: #selector(onButtonMoveToNext), for: .touchUpInside)
        self.view.addSubview(btnMoveToNext)
        
        rect = CGRect(x: 100, y: 177, width: 77, height: 27)
        btnMoveToNext = UIButton(frame: rect)
        btnMoveToNext.setTitle("flyDown", for: .normal)
        btnMoveToNext.titleLabel?.font = font
        btnMoveToNext.backgroundColor = .red
        btnMoveToNext.addTarget(self, action: #selector(onButtonFlyDown), for: .touchUpInside)
        self.view.addSubview(btnMoveToNext)
        
        rect = CGRect(x: 100, y: 217, width: 77, height: 27)
        let btnflyCurve = UIButton(frame: rect)
        btnflyCurve.setTitle("flyCurve", for: .normal)
        btnflyCurve.titleLabel?.font = font
        btnflyCurve.backgroundColor = .red
        btnflyCurve.addTarget(self, action: #selector(onButtonFlyCurve), for: .touchUpInside)
        self.view.addSubview(btnflyCurve)
        
        rect = CGRect(x: 100, y: 257, width: 77, height: 27)
        let btnTurnLeft = UIButton(frame: rect)
        btnTurnLeft.setTitle("turnLeft", for: .normal)
        btnTurnLeft.titleLabel?.font = font
        btnTurnLeft.backgroundColor = .red
        btnTurnLeft.addTarget(self, action: #selector(onButtonTurnLeft), for: .touchUpInside)
        self.view.addSubview(btnTurnLeft)
    }

    func getAnimationExtraAttributes() -> [Int: Any]? {
        return nil
    }
    
    func createDroneModel(contentView: UIView, stayAndFlyImage: [UIImageView], topAndLeftCOntraints: [NSLayoutConstraint], points: [CGPoint]) {
        _droneObject = DroneModel(contentView: contentView, stayAndFlyImage: stayAndFlyImage, topAndLeftCOntraints: topAndLeftCOntraints, points: points)
        if let attrs = getAnimationExtraAttributes() {
            _droneObject.setExtraAttributes(extra: attrs)
        }
    }
    
    func buildDroneObjects() {
        var aiPoints  = [UIView]()
        
        for i in 1..<20 {
            if let view = self.view.viewWithTag(i) {
                aiPoints.append(view)
                if view is UIActivityIndicatorView {
                    view.isHidden = true
                }
            }
        }
        if aiPoints.count > 0 {
            let posPoints = DroneModel.makePoints(views: aiPoints)
            createDroneModel(contentView: self.view, stayAndFlyImage: [imageStay, imageFly], topAndLeftCOntraints: [imageFlyTopConstraint, imageFlyLeftConstraint], points: posPoints)
        }
    }

    func takeOff() {
        DroneLog.debug("_droneObject.takeOff()")
        _ = _droneObject.takeOff()
    }
    
    func flyUp() {
        DroneLog.debug("flyUp()")
        _ = _droneObject.flyUp()
    }
    
    func flyDown() {
        DroneLog.debug("_droneObject.flyDown()")
        _ = _droneObject.flyDown()
    }
    
    func flyCurve() {
        assert(false)
    }

    func land() {
        _ = _droneObject.land()
    }

    func turnLeft(degree: Int) {
        _ = _droneObject.turnLeft(degree: degree)
    }
    
    func turnRight(degree: Int) {
        _ = _droneObject.turnRight(degree: degree)
    }
    
    func moveToNext() {
        _ = _droneObject.moveToNext()
    }
    
    func moveToEnd() {
        _ = _droneObject.moveToEnd()
    }
    
    func handleJump() {
        _ = _droneObject.moveToNext()
    }
    
    func handlePadID(value: Int) {
        
    }
    
    func handlePadPos(x: Double, y: Double, z: Double) {
        
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
            // DroneLog.debug(String(format: "action: %@", action))
            switch action {
            case "takeoff":
                self.takeOff()
            case "land":
                self.land()
            case "turnLeft":
                var degree = 360
                if case let .integer(value)? = command["value"] {
                    degree = value
                }
                self.turnLeft(degree: degree)
            case "turnRight":
                var degree = 360
                if case let .integer(value)? = command["value"] {
                    degree = value
                }
                self.turnRight(degree: degree)
            case "flyForward":
                self.moveToNext()
            case "flyBackward":
                self.moveToNext()
            case "flyUp":
                self.flyUp()
            case "flyDown":
                self.flyDown()
            case "flyLeft":
                self.moveToNext()
            case "flyRight":
                self.moveToNext()
            case "flyCurve":
                self.flyCurve()
            case "go":
                self.moveToNext()
            case "jump":
                self.handleJump()
            case "getPadID":
                if case let .integer(value)? = command["value"] {
                    self.handlePadID(value: value)
                }
            case "getPadPos":
                if case let .floatingPoint(x)? = command["x"],
                    case let .floatingPoint(y)? = command["y"],
                    case let .floatingPoint(z)? = command["z"]{
                    self.handlePadPos(x: x, y: y, z: z)
                }
            default:
                handled = false
            }
        } else {
            handled = false
            DroneLog.error("action not avaiable")
        }
        return handled
    }
}

@objc(FlyingDroneModelBaseViewController)
class FlyingDroneModelBaseViewController: LiveViewBaseController {
    
    override func createDroneModel(contentView: UIView, stayAndFlyImage: [UIImageView], topAndLeftCOntraints: [NSLayoutConstraint], points: [CGPoint]) {
        _droneObject = DroneModelFlying(contentView: contentView, stayAndFlyImage: stayAndFlyImage, topAndLeftCOntraints: topAndLeftCOntraints, points: points)
        if let attrs = getAnimationExtraAttributes() {
            _droneObject.setExtraAttributes(extra: attrs)
        }
    }
}

