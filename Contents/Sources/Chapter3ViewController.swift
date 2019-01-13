//
//  Chapter3ViewController.swift
//  Chapter3ViewController
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

@objc(WithGalaxyIdViewContoller)
class WithGalaxyIdViewContoller: FlyingDroneModelBaseViewController {
    @IBOutlet weak var lbGalaxyName: UILabel!
    var _lbGalaxyId: UILabel!
    
    override func resetLiveView() {
        super.resetLiveView()
        _lbGalaxyId.text = ""
    }
    
    override func handlePadID(value: Int) {
        super.handlePadID(value: value)
        _lbGalaxyId.text = String(format: "%d", value)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildGalaxyIdValueLabel()
    }
    
    func buildGalaxyIdValueLabel() {
        let view = buildBackgroundView(referencedView: lbGalaxyName)
        _lbGalaxyId = buildValueLabel(newView: view)
    }
    
    func buildBackgroundView(referencedView: UIView) -> UIView {
        let newView = UIView()
        newView.backgroundColor = UIColor(red: 0.05, green: 0.12, blue: 0.16, alpha: 0.5)
        view.addSubview(newView)
        let cornerRadius: CGFloat = 5.5
        newView.layer.cornerRadius = cornerRadius
        newView.layer.masksToBounds = cornerRadius > 0
        
        newView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(
            item: newView, attribute: .leading, relatedBy: .equal,
            toItem: referencedView, attribute: .trailing, multiplier: 1, constant: 2)
        
        let verticalConstraint = NSLayoutConstraint(
            item: newView, attribute: .centerY, relatedBy: .equal,
            toItem: referencedView, attribute: .centerY, multiplier: 1, constant: 0)
        
        let widthConstraint = NSLayoutConstraint(
            item: newView, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 51)
        
        let heightConstraint = NSLayoutConstraint(
            item: newView, attribute: .height, relatedBy: .equal,
            toItem: referencedView, attribute: .height, multiplier: 1, constant: 6)
        
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        return newView
    }
    
    func buildValueLabel(newView: UIView) -> UILabel {
        let lbValue = UILabel()
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
        return lbValue
    }

}

@objc(Chapter3_1ViewController)
class Chapter3_1ViewController: WithGalaxyIdViewContoller {
    
    @IBOutlet var xyzOfA: [UILabel]!

    var _valueLabels = [UILabel]()

    override func resetLiveView() {
        super.resetLiveView()
        for v in _valueLabels {
            v.text = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildAllValueLables()
    }
    
    func buildAllValueLables() {
        for rv in xyzOfA {
            let view = buildBackgroundView(referencedView: rv)
            let lb = buildValueLabel(newView: view)
            _valueLabels.append(lb)
        }
    }
    
    override func handlePadPos(x: Double, y: Double, z: Double) {
        super.handlePadPos(x: x, y: y, z: z)
        _valueLabels[0].text = String(format: "%0.0f", x)
        _valueLabels[1].text = String(format: "%0.0f", y)
        _valueLabels[2].text = String(format: "%0.0f", z)
    }
}

@objc(Chapter3_2ViewController)
class Chapter3_2ViewController: Chapter3_1ViewController {
    
    @IBOutlet var xyzOfB: [UILabel]!
    
    var _valueLabelsB = [UILabel]()
    
    var _posCount = 0

    override func resetLiveView() {
        super.resetLiveView()
        _posCount = 0
        for v in _valueLabelsB {
            v.text = ""
        }
    }
    
    override func buildAllValueLables() {
        super.buildAllValueLables()
        for rv in xyzOfB {
            let view = buildBackgroundView(referencedView: rv)
            let lb = buildValueLabel(newView: view)
            _valueLabelsB.append(lb)
        }
    }
    
    override func handlePadPos(x: Double, y: Double, z: Double) {
        _posCount += 1
        if _posCount == 1 {
            super.handlePadPos(x: x, y: y, z: z)
        }
        if _posCount == 2 {
            _valueLabelsB[0].text = String(format: "%0.0f", x)
            _valueLabelsB[1].text = String(format: "%0.0f", y)
            _valueLabelsB[2].text = String(format: "%0.0f", z)
        }
    }
}

@objc(Chapter3_3ViewController)
class Chapter3_3ViewController: WithGalaxyIdViewContoller {
  
}

@objc(Chapter3_4ViewController)
class Chapter3_4ViewController: WithGalaxyIdViewContoller {
    @IBOutlet weak var lbGalaxyId2: UILabel!
    
    var _lbGalaxyId2: UILabel!

    var _padCount = 0
    
    override func resetLiveView() {
        super.resetLiveView()
        _padCount = 0
        _lbGalaxyId2.text = ""
    }
    
    override func buildGalaxyIdValueLabel() {
        super.buildGalaxyIdValueLabel()
        let view = buildBackgroundView(referencedView: lbGalaxyId2)
        _lbGalaxyId2 = buildValueLabel(newView: view)
    }
    
    override func getAnimationExtraAttributes() -> [Int: Any]? {
        return [
            0:[
                "duration": 2.0,
                "alpha1": 0.0,
                "alpha2": 1.0
            ],
        ]
    }
    
    override func handlePadID(value: Int) {
        _padCount += 1
        if _padCount == 1 {
            super.handlePadID(value: value)
        }
        if _padCount == 2 {
            _lbGalaxyId2.text = String(format: "%d", value)
        }
    }
}

@objc(Chapter3_5ViewController)
class Chapter3_5ViewController: Chapter3_4ViewController {
}

@objc(Chapter3_6ViewController)
class Chapter3_6ViewController: WithGalaxyIdViewContoller {
    @IBOutlet weak var uiScene2: UIView!
    @IBOutlet weak var uiScene1: UIView!
    
    
    override func createDroneModel(contentView: UIView, stayAndFlyImage: [UIImageView], topAndLeftCOntraints: [NSLayoutConstraint], points: [CGPoint]) {
        var fixPoints = [CGPoint]()
        for i in 0..<points.count-1 {
            fixPoints.append(points[i])
        }
        super.createDroneModel(contentView: contentView, stayAndFlyImage: stayAndFlyImage, topAndLeftCOntraints: topAndLeftCOntraints, points: fixPoints)
    }
    
    override func resetLiveView() {
        super.resetLiveView()
        UIView.animate(withDuration: 0.5, animations: {
            self.uiScene1.alpha = 1
        }, completion: nil)
    }

    override func getAnimationExtraAttributes() -> [Int: Any]? {
        return [
            0: [
                "duration": 1,
                "alpha1": 0.0,
                "alpha2": 0.0
            ],
            1: [
                "duration": 1,
                "alpha1": 0.0,
                "alpha2": 1.0
            ],
            2: [
                "duration": 1,
                "alpha1": 0.0,
                "alpha2": 1.0
            ]
        ]
    }
    
    override func handleJump() {
        _ = _droneObject.moveToNext()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.5, animations: {
                self.uiScene1.alpha = 0.0
            }, completion: { (result) in
                _ = self._droneObject.moveToNext()
                _ = self._droneObject.turnLeft(degree: 180)
                self.uiScene1.alpha = 0
                self.uiScene2.alpha = 1
                
            })
        }
    }
}
@objc(Chapter3_7ViewController)
class Chapter3_7ViewController: FlyingDroneModelBaseViewController {
}

