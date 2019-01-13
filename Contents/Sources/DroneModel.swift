//
//  DroneModel.swift
//  DroneModel
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


enum DroneModelStatus {
    case landing
    case flying
}

class DroneModel: NSObject {
    var _stayImage: UIImageView
    var _flyImage: UIImageView
    
    var _topContraint: NSLayoutConstraint
    var _leftContraint: NSLayoutConstraint
    
    var _originTopConstant: CGFloat
    var _originLeftConstant: CGFloat
    
    var _scaledTransform : CGAffineTransform!
    var _scaledAndRotatedTransform : CGAffineTransform!

    var _points: [CGPoint]
    var _extraAttributes = [Int: Any]()
    
    var _chainAnimation: EAAnimationFuture?
    
    var _contentView: UIView
    
    var _currentPointIndex: Int = 0
    
    var _status : DroneModelStatus = .landing
    
    var _isReachEnd = false
    
    var isReachEnd: Bool {
        return _isReachEnd
    }
    
    public init (contentView: UIView, stayAndFlyImage: [UIImageView], topAndLeftCOntraints: [NSLayoutConstraint], points: [CGPoint]) {
        
        _contentView = contentView
        _stayImage = stayAndFlyImage.first!
        _flyImage  = stayAndFlyImage.last!
        
        _topContraint = topAndLeftCOntraints.first!
        _leftContraint = topAndLeftCOntraints.last!

        _originTopConstant = _topContraint.constant
        _originLeftConstant = _leftContraint.constant

        _points = points
        super.init()
        self.initialize()
    }
    
    func initialize() {}
    
    func setExtraAttributes( extra: [Int: Any]) {
        self._extraAttributes = extra
    }
    
    func reset() {
        _currentPointIndex = 0
        _isReachEnd = false
        
        _topContraint.constant = _originTopConstant
        _leftContraint.constant = _originLeftConstant
        
        _scaledTransform = CGAffineTransform(scaleX: 1, y: 1)
        _scaledAndRotatedTransform = _scaledTransform
        self._flyImage.transform = self._scaledTransform
        self._stayImage.alpha = 1.0
        self._flyImage.alpha = 0.0
    }

    func takeOff() -> Bool {
        _currentPointIndex = 0
        _isReachEnd = false
        
        _topContraint.constant = _originTopConstant
        _leftContraint.constant = _originLeftConstant
        
        let result = _status == .landing
        if result {
            _scaledTransform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            _scaledAndRotatedTransform = _scaledTransform
            _chainAnimation = UIView.animateAndChain(withDuration: 1, delay: 0.0, options: [], animations: {
                self._stayImage.alpha = 0.0
                self._flyImage.alpha = 1.0
            }, completion: nil).animateAndChain(withDuration: 1, delay: 0.0, options: [], animations: {
                self._flyImage.transform = self._scaledTransform
                self._contentView.layoutIfNeeded()
            }, completion: nil)
            _status = .flying
        }
        return result
    }
    
    func flyUp() -> Bool {
        let result = _status == .flying
        if result {
            _scaledTransform = CGAffineTransform(scaleX: 1.7, y: 1.7)
            _scaledAndRotatedTransform = _scaledTransform
            _chainAnimation = UIView.animateAndChain(withDuration: 1.0, delay: 0.0, options: [], animations: {
                self._flyImage.transform = self._scaledTransform
                self._contentView.layoutIfNeeded()
            }, completion: nil)
        }
        return result
    }
    
    func flyDown() -> Bool {
        let result = _status == .flying
        if result {
            _scaledTransform = _scaledTransform.scaledBy(x: 0.76, y: 0.76)
            _scaledAndRotatedTransform = _scaledTransform
            _chainAnimation = UIView.animateAndChain(withDuration: 1.0, delay: 0.0, options: [], animations: {
                self._flyImage.transform = self._scaledTransform
                self._contentView.layoutIfNeeded()
            }, completion: nil)
        }
        return result
    }
    
    func turnLeft(degree: Int) -> Bool {
        let result = _status == .flying
        if result {
            let rad = -(Double(degree) * (Double.pi / 180.0))
            _scaledAndRotatedTransform = _scaledAndRotatedTransform.rotated(by: CGFloat(rad))
            _chainAnimation = UIView.animateAndChain(withDuration: 1.0, delay: 0.0, options: [], animations: {
                self._flyImage.transform = self._scaledAndRotatedTransform
                self._contentView.layoutIfNeeded()

            }, completion: {_ in
                print("turnLeft")
            })
        }
        return result
    }

    func turnRight(degree: Int) -> Bool {
        let result = _status == .flying
        if result {
            let rad = (Double(degree) * (Double.pi / 180.0))
            _scaledAndRotatedTransform = _scaledAndRotatedTransform.rotated(by: CGFloat(rad))
            _chainAnimation = UIView.animateAndChain(withDuration: 1.0, delay: 0.0, options: [], animations: {
                self._flyImage.transform = self._scaledAndRotatedTransform
                self._contentView.layoutIfNeeded()

            }, completion: {_ in
                print("turnRight")
            })
        }
        return result
    }
    
    func land() -> Bool {

        let result = _status == .flying
        if result {
            _chainAnimation = UIView.animateAndChain(withDuration: 2.0, delay: 0.0, options: [], animations: {

                self._flyImage.transform = self._scaledTransform.scaledBy(x: 0.76, y: 0.76)
                self._contentView.layoutIfNeeded()
                
            }, completion: {_ in
                self._stayImage.alpha = 1.0
                self._flyImage.alpha = 0.0
                
                self._topContraint.constant = self._originTopConstant
                self._leftContraint.constant = self._originLeftConstant
                self._flyImage.transform = CGAffineTransform.identity
                self._contentView.layoutIfNeeded()
            })
            _status = .landing
        }
        return result
    }
    
    func moveToEnd() -> Bool {
        DroneLog.debug(String(format: "points count: %d", _points.count))
        let result = _status == .flying && !_points.isEmpty && _currentPointIndex < _points.count && !_isReachEnd
        
        if result {
            DroneLog.debug(String(format: "self._leftContraint: %d", self._leftContraint.constant))
            let point = _points[_currentPointIndex]
            _currentPointIndex += 1
            var anim : EAAnimationFuture? = UIView.animateAndChain(withDuration: 0.7, delay: 0.0, options: [.beginFromCurrentState], animations: {
                self._topContraint.constant += point.y
                self._leftContraint.constant += point.x
                self._contentView.layoutIfNeeded()
            }, completion: nil)
            let start = _currentPointIndex
            for i in start..<_points.count {
                DroneLog.debug(String(format: "index: %d, x: %d, y: %d", i, point.x, point.y))
                let point = _points[i]
                anim = anim?.animateAndChain(withDuration: 0.7, delay: Double(start) * 0.5, options: [.beginFromCurrentState], animations: {
                self._topContraint.constant += point.y
                self._leftContraint.constant += point.x
                self._contentView.layoutIfNeeded()
                }, completion: nil)
                _currentPointIndex += 1
            }
            _isReachEnd = true
        } else {
            DroneLog.debug("status error")
        }
        return result
    }

    func moveToNext() -> Bool {
        let result = _status == .flying && _currentPointIndex < _points.count && !_isReachEnd
        if result {
            let point = self._points[_currentPointIndex]
            var alpha1: CGFloat? = nil
            var alpha2: CGFloat? = nil
            var duration: TimeInterval = 1.0
            if let attr = self._extraAttributes[self._currentPointIndex] as? [String: Any] {
                if let a1 = attr["alpha1"] as? Double, let a2 = attr["alpha2"] as? Double {
                    alpha1 = CGFloat(a1)
                    alpha2 = CGFloat(a2)
                }
                
                if let value = attr["duration"] as? Double {
                    duration = value
                }
            }
            
            _chainAnimation = UIView.animateAndChain(withDuration: duration, delay: 0.0, options: [.beginFromCurrentState], animations: {
                self._topContraint.constant += point.y
                self._leftContraint.constant += point.x
                self._contentView.layoutIfNeeded()
                
                if let value = alpha1 {
                    self._flyImage.alpha = value
                }
            }, completion: nil)
            
            if let value = alpha2, _currentPointIndex + 1 < _points.count {
                _currentPointIndex += 1
                let point = self._points[_currentPointIndex]
                _chainAnimation = _chainAnimation?.animateAndChain(withDuration: duration / 2, delay: 0.0, options: [.beginFromCurrentState], animations: {
                    self._flyImage.alpha = value
                    self._topContraint.constant += point.y
                    self._leftContraint.constant += point.x
                    self._contentView.layoutIfNeeded()
                    }, completion: nil)
            }

            _currentPointIndex += 1
        } else {
            _isReachEnd = true
            DroneLog.error("status error")
        }
        return result
    }

    public class func makePoints(views: [UIView]) -> [CGPoint] {
        var posPoints: [CGPoint] = [CGPoint]()
        if !views.isEmpty {
            for i in 0..<(views.count-1) {
                let ap1 = views[i]
                let ap2 = views[i + 1]
                let posPoint = CGPoint(
                    x: ap2.frame.origin.x -  ap1.frame.origin.x,
                    y: ap2.frame.origin.y -  ap1.frame.origin.y // - center + delta
                )
                posPoints.append(posPoint)
            }
            let ap1 = views.last!
            let ap2 = views.first!
            let posPoint = CGPoint(
                x: ap2.frame.origin.x -  ap1.frame.origin.x,
                y: ap2.frame.origin.y -  ap1.frame.origin.y // - center + delta
            )
            posPoints.append(posPoint)
        }
        return posPoints
    }
}

class DroneModelLoop: DroneModel {
    init(contentView: UIView, stayAndFlyImage: [UIImageView], topAndLeftCOntraints: [NSLayoutConstraint], points: [CGPoint], currentIndex: Int) {
        super.init(contentView: contentView, stayAndFlyImage: stayAndFlyImage, topAndLeftCOntraints: topAndLeftCOntraints, points: points)
        _currentPointIndex = currentIndex
    }
    
    override func reset() {
        super.reset()
        self._stayImage.alpha = 0.3
        self._flyImage.alpha = 0.3
    }
    
    override func takeOff() -> Bool {
        reset()
        _status = .flying
        self._stayImage.alpha = 0
        self._flyImage.alpha = 1
        return true
    }
    
    override func land() -> Bool {
        _status = .landing
        return true
    }
    
    override func moveToNext() -> Bool {
         _currentPointIndex = _currentPointIndex % _points.count
        let result = _status == .flying
        if result {
            let point = self._points[_currentPointIndex]
            _chainAnimation = UIView.animateAndChain(withDuration: 1.5, delay: 0.0, options: [.beginFromCurrentState], animations: {
                self._topContraint.constant += point.y
                self._leftContraint.constant += point.x
                self._contentView.layoutIfNeeded()
            }, completion: nil)

            _currentPointIndex += 1
        } else {
            DroneLog.error("status error")
        }
        return result
    }
}

class DroneModelFlying: DroneModel {
    override func takeOff() -> Bool {
        reset()
        _status = .flying
        return true
    }
    
    override func land() -> Bool {
        _status = .landing
        return true
    }
    
    override func reset() {
        super.reset()
        self._stayImage.alpha = 0.0
        self._flyImage.alpha = 1.0
    }
}

class DroneModelCurveMoving: DroneModelFlying, CAAnimationDelegate {
    
    var dPoints = [CGPoint]()
    override func initialize() {
        let xD = self._flyImage.frame.origin.x
        let yD = self._flyImage.frame.origin.y

        var lastPoint = CGPoint(x: xD + self._flyImage.frame.width / 2, y: yD + self._flyImage.frame.height / 2)
        dPoints.append(lastPoint)
        for i in 0..<_points.count {
            let tmp = _points[i]
            let point = CGPoint(x: tmp.x + lastPoint.x, y: tmp.y + lastPoint.y)
            lastPoint = point
            dPoints.append(point)
        }
    }
    let _pointsPerStep = 3
    var _rotated = false
    func curveMove(stepsToMove: UInt) -> Bool {
        DroneLog.debug(String(format: "points count: %d", _points.count))
        let stepLeft = ( _points.count / _pointsPerStep ) >= stepsToMove && _currentPointIndex < _points.count
        let result = _status == .flying && !_points.isEmpty && stepLeft && !_isReachEnd
        
        if result {
            let pathAnimation = CAKeyframeAnimation(keyPath: "position")
            pathAnimation.duration = 3.0
            pathAnimation.isRemovedOnCompletion = false
            pathAnimation.fillMode = kCAFillModeForwards
            
            pathAnimation.rotationMode = kCAAnimationRotateAuto
            pathAnimation.calculationMode = kCAAnimationLinear
            
            let curvedPath = CGMutablePath()

            
            let startIndex = _currentPointIndex / _pointsPerStep
            let index = _currentPointIndex > 0 ? _currentPointIndex - 1 : _currentPointIndex
            curvedPath.move(to: dPoints[index])
            for i in startIndex..<Int(stepsToMove) {
                let p0 = dPoints[i * 3]
                let p1 = dPoints[i * 3 + 1]
                let p2 = dPoints[i * 3 + 2]
                curvedPath.addCurve(to: p2, control1: p0, control2: p1)
                curvedPath.move(to: p2)
            }

            _currentPointIndex += _pointsPerStep * ( startIndex + 1)
            
            curvedPath.closeSubpath()
            pathAnimation.path = curvedPath
            pathAnimation.delegate = self

            self._flyImage.layer.add(pathAnimation, forKey: "position")
            
            var degree: CGFloat = -10
            if self._rotated {
                self._rotated = true
                degree = -20
            }

            let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
            rotateAnimation.values = [degree]
            rotateAnimation.duration = 3.0
            rotateAnimation.isRemovedOnCompletion = false
            rotateAnimation.rotationMode = kCAAnimationRotateAuto
            
            self._flyImage.layer.add(rotateAnimation, forKey: "transform.rotation")

        }
        return result
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let degree: CGFloat = -10
        self._flyImage.transform = _scaledAndRotatedTransform.rotated(by: degree)
    }
}
