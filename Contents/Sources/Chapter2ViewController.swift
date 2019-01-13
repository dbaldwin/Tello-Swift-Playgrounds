//
//  Chapter2ViewController.swift
//  Chapter2ViewController
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

@objc(Chapter2_1ViewController)
class Chapter2_1ViewController: LiveViewBaseController {
    @IBOutlet weak var lbHeight: UILabel!
    var _heightValueView: UIView? = nil
    var _lbValue: UILabel!
    override func resetLiveView() {
        super.resetLiveView()
        _lbValue.text = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildHeightValueView()
    }
    
    func buildHeightValueView() {
        if _heightValueView == nil {
            
            let newView = UIView()
            newView.backgroundColor = UIColor(red: 0.05, green: 0.12, blue: 0.16, alpha: 0.5)
            view.addSubview(newView)
            let cornerRadius: CGFloat = 5.5
            newView.layer.cornerRadius = cornerRadius
            newView.layer.masksToBounds = cornerRadius > 0

            _heightValueView = newView
            
            newView.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(
                item: newView, attribute: .leading, relatedBy: .equal,
                toItem: lbHeight, attribute: .trailing, multiplier: 1, constant: 2)
            
            let verticalConstraint = NSLayoutConstraint(
                item: newView, attribute: .centerY, relatedBy: .equal,
                toItem: lbHeight, attribute: .centerY, multiplier: 1, constant: 0)
            
            let widthConstraint = NSLayoutConstraint(
                item: newView, attribute: .width, relatedBy: .equal,
                toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 51)
            
            let heightConstraint = NSLayoutConstraint(
                item: newView, attribute: .height, relatedBy: .equal,
                toItem: lbHeight, attribute: .height, multiplier: 1, constant: 7)
            
            NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
            
            let lbValue = UILabel()
            _lbValue = lbValue
            lbValue.backgroundColor = .clear
            lbValue.textColor = .red
            lbValue.font = UIFont.boldSystemFont(ofSize: 15)
            lbValue.textAlignment = .center
            lbValue.translatesAutoresizingMaskIntoConstraints = false
            newView.addSubview(lbValue)

            let hc = NSLayoutConstraint(
                item: lbValue, attribute: .leading, relatedBy: .equal,
                toItem: newView, attribute: .leading, multiplier: 1, constant: 0)
            
            let vc = NSLayoutConstraint(
                item: lbValue, attribute: .centerY, relatedBy: .equal,
                toItem: newView, attribute: .centerY, multiplier: 1, constant: 0)
            
            let wc = NSLayoutConstraint(
                item: lbValue, attribute: .width, relatedBy: .equal,
                toItem: newView, attribute: .width, multiplier: 1, constant: 0)
            
            let hc1 = NSLayoutConstraint(
                item: lbValue, attribute: .height, relatedBy: .equal,
                toItem: newView, attribute: .height, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([hc, vc, wc, hc1])
            
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
            case "getHeight":
                if case let .floatingPoint(value)? = command["value"] {
                    _lbValue.text = "\(UInt(value))"
                }
            default:
                handled = false
            }
        }
        return handled
    }
}

@objc(Chapter2_2ViewController)
class Chapter2_2ViewController: LiveViewBaseController {
}

@objc(Chapter2_3ViewController)
class Chapter2_3ViewController: LiveViewBaseController {
    override func createDroneModel(contentView: UIView, stayAndFlyImage: [UIImageView], topAndLeftCOntraints: [NSLayoutConstraint], points: [CGPoint]) {
        _droneObject = DroneModelFlying(contentView: contentView, stayAndFlyImage: stayAndFlyImage, topAndLeftCOntraints: topAndLeftCOntraints, points: points)
        if let attrs = getAnimationExtraAttributes() {
            _droneObject.setExtraAttributes(extra: attrs)
        }
    }
}

@objc(Chapter2_4ViewController)
class Chapter2_4ViewController: LiveViewBaseController {
    override func createDroneModel(contentView: UIView, stayAndFlyImage: [UIImageView], topAndLeftCOntraints: [NSLayoutConstraint], points: [CGPoint]) {
        _droneObject = DroneModelCurveMoving(contentView: contentView, stayAndFlyImage: stayAndFlyImage, topAndLeftCOntraints: topAndLeftCOntraints, points: points)
        if let attrs = getAnimationExtraAttributes() {
            _droneObject.setExtraAttributes(extra: attrs)
        }
    }
    override func flyCurve() {
        if let drone = _droneObject as? DroneModelCurveMoving {
            _ = drone.curveMove(stepsToMove: UInt(3))
        }
    }
    
    override func getAnimationExtraAttributes() -> [Int: Any]? {
        var attrs = [Int: Any]()
        for i in 0..<8 {
            attrs[i] = [ "duration": 1.0 ]
        }
        return attrs
    }
}

@objc(Chapter2_5ViewController)
class Chapter2_5ViewController: Chapter2_1ViewController {
    override func createDroneModel(contentView: UIView, stayAndFlyImage: [UIImageView], topAndLeftCOntraints: [NSLayoutConstraint], points: [CGPoint]) {
        _droneObject = DroneModelCurveMoving(contentView: contentView, stayAndFlyImage: stayAndFlyImage, topAndLeftCOntraints: topAndLeftCOntraints, points: points)
        if let attrs = getAnimationExtraAttributes() {
            _droneObject.setExtraAttributes(extra: attrs)
        }
    }
    var _currentStep = 1
    override func flyCurve() {
        if let drone = _droneObject as? DroneModelCurveMoving {
            _ = drone.curveMove(stepsToMove: UInt(_currentStep))
            _currentStep += 1
        }
    }
}

@objc(Chapter2_6ViewController)
class Chapter2_6ViewController: LiveViewBaseController {
}

@objc(Chapter2_7ViewController)
class Chapter2_7ViewController: LiveViewBaseController {
}

