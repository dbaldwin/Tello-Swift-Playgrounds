//
//  Utils.swift
//  Utils
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
 * Created by XIAOWEI WANG on 23/08/2018.
 * support@ryzerobotics.com
 *
 
 */

import Foundation
import PlaygroundSupport

public class Assessor {

    var drone: Drone? = nil
    var manager: DroneManager? = nil
    public typealias Assessment = (Action, [String])
    
    public enum Action {
        case takeOff
        case land
        case getHeight
        case getPadID
        case getPadPos
        case setSpeed(cms: UInt)
        case connectAP(ssid: String, password: String)
        case flyUp(cm: UInt)
        case flyDown(cm: UInt)
        case flyLeft(cm: UInt)
        case flyRight(cm: UInt)
        case flyForward(cm: UInt)
        case flyBackward(cm: UInt)
        case flyLine(x: Int, y: Int, z: Int, pad: Int)
        case flyCurve(x1: Int, y1: Int, z1: Int, x2: Int,y2: Int, z2: Int)
        case transit(x: Int, y: Int, z: Int, pad1: Int, pad2: Int)
        case turnLeft(degree: Int)
        case turnRight(degree: Int)

        case allAnyOrder([Action])
        case all([Action])
    }
    
    private var isLowBattery: Bool {
        if let drone = self.drone {
            return drone.isLowBattery
        }
        return false
    }

    private var actions = [Action]()
    
    public func add(action: Action) {
        actions.append(action)
    }

    public init() {
    }
    
    public func check(expected expectedActions: [Assessment], success: String?)
        -> PlaygroundPage.AssessmentStatus {
            if drone != nil {
                guard drone!.ready else {
                    let failed = NSLocalizedString("### Tello Not Found!", comment: "Tello Not Found!")
                    let soulution = NSLocalizedString("### Make sure the power indicator is on!", comment: "Tello Not Found!")
                    return .fail(hints: [failed], solution: soulution)
                }
                
                guard !isLowBattery else {
                    let failed = NSLocalizedString("### Low Battery!", comment: "Low Battery")
                    let soulution = NSLocalizedString("### Make sure the battery level is above 20%!", comment: "Low Battery!")
                    return .fail(hints: [failed], solution: soulution)
                }
            }
            
            if manager != nil {
                guard !manager!.tellos.isEmpty else {
                    let failed = NSLocalizedString("### Tello Not Found!", comment: "Tello Not Found!")
                    let soulution = NSLocalizedString("### Make sure the power indicator is on!", comment: "Tello Not Found!")
                    return .fail(hints: [failed], solution: soulution)
                }
            }

            var actionsIdx = 0
            for expectedAction in expectedActions {
                if !checkExpectedAction(expected: expectedAction.0, actionIdx: &actionsIdx) {
                    return .fail(hints: expectedAction.1, solution: nil)
                }
            }
            return .pass(message: success)
    }
    
    private func checkExpectedAction(expected: Action, actionIdx: inout Int) -> Bool {
        while actionIdx < actions.count {
            let actual = actions[actionIdx]
            switch expected {
            case .allAnyOrder(let anyOrderActions):
                let startIdx = actionIdx
                var endIdx = actionIdx
                for action in anyOrderActions {
                    var found = false
                    while !found && actionIdx < actions.count {
                        if checkExpectedAction(expected: action, actionIdx: &actionIdx) {
                            found = true
                            endIdx = max(endIdx, actionIdx)
                            actionIdx = startIdx
                        } else {
                            actionIdx += 1
                        }
                    }
                }
                if actionIdx < actions.count {
                    actionIdx = endIdx
                    return true
                }
            case .all(let allAction):
                for action in allAction {
                    var found = false
                    while !found && actionIdx < actions.count {
                        if checkExpectedAction(expected: action, actionIdx: &actionIdx) {
                            found = true
                        } else {
                            actionIdx += 1
                        }
                    }
                }
                if actionIdx < actions.count {
                    return true
                }
            default:
                if checkAction(expected: expected, actual: actual) {
                    actionIdx += 1
                    return true
                }
            }
            actionIdx += 1
        }
        return false
    }
    
    private func checkAction(expected: Action, actual: Action) -> Bool {
        switch expected {
        case .takeOff:
            if case .takeOff = actual {
                return true
            }
        case .land:
            if case .land = actual {
                return true
            }
        case .getHeight:
            if case .getHeight = actual {
                return true
            }
        case .getPadID:
            if case .getPadID = actual {
                return true
            }
        case .getPadPos:
            if case .getPadPos = actual {
                return true
            }
        case let .setSpeed(expectedSpeed):
            if case let .setSpeed(speed) = actual,
                Float(expectedSpeed).sign == Float(speed).sign {
                return true
            }
        case .connectAP(_, _):
            return true
        case let .turnLeft(expectedDegree):
            if case let .turnLeft(degree) = actual,
                Float(expectedDegree).sign == Float(degree).sign{
                return true
            }
        case let .turnRight(expectedDegree):
            if case let .turnRight(degree) = actual,
                Float(expectedDegree).sign == Float(degree).sign{
                return true
            }
        case let .flyUp(expectedDistance):
            if case let .flyUp(distance) = actual,
                Float(expectedDistance).sign == Float(distance).sign {
                return true
            }
        case let .flyDown(expectedDistance):
            if case let .flyDown(distance) = actual,
                Float(expectedDistance).sign == Float(distance).sign {
                return true
            }
        case let .flyLeft(expectedDistance):
            if case let .flyLeft(distance) = actual,
                Float(expectedDistance).sign == Float(distance).sign {
                return true
            }
        case let .flyRight(expectedDistance):
            if case let .flyRight(distance) = actual,
                Float(expectedDistance).sign == Float(distance).sign {
                return true
            }
        case let .flyForward(expectedDistance):
            if case let .flyForward(distance) = actual,
                Float(expectedDistance).sign == Float(distance).sign {
                return true
            }
        case let .flyBackward(expectedDistance):
            if case let .flyBackward(distance) = actual,
                Float(expectedDistance).sign == Float(distance).sign {
                return true
            }
        case let .flyLine(x, y, z, marker):
            if case let .flyLine(x1, y1, z1, marker1) = actual,
                (Float(x).sign, Float(y).sign, Float(z).sign, marker) == (Float(x1).sign,Float(y1).sign,Float(z1).sign, marker1) {
                return true
            }
        case let .flyCurve(x1, y1, z1, x2, y2, z2):
            if case let .flyCurve(_x1, _y1, _z1, _x2, _y2, _z2) = actual,
                (Float(_x1).sign, Float(_y1).sign, Float(_z1).sign, Float(_x2).sign, Float(_y2).sign, Float(_z2).sign) == (Float(x1).sign, Float(y1).sign, Float(z1).sign, Float(x2).sign, Float(y2).sign, Float(z2).sign) {
                return true
            }
        case let .transit(x, y, z, marker1, marker2):
            if case let .transit(_x, _y, _z, _marker1, _marker2) = actual{
                let r1 = (Float(_x).sign, Float(_y).sign, Float(_z).sign, _marker1 * 0, _marker2 * 0)
                let r2 = (Float(x).sign, Float(y).sign, Float(z).sign, marker1 * 0, marker2 * 0)
                return r2 == r1
            }
        default:
            break
        }
        return false
    }
}
