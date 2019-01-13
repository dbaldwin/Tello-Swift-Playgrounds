//
//  MoveParam.swift
//  MoveParam
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


public struct MoveParam {
    
    enum MoveMode {
        case MoveAtSpeedForSeconds(MoveDirection, UInt, UInt)
        case MoveAtSpeed(MoveDirection, UInt)
        case MoveForSeconds(MoveDirection, UInt)
    }
 
    private var _speed: UInt
    private var _direction: MoveDirection
    private var _duration: UInt
    private var _moveMode: MoveMode
    
    var moveMode: MoveMode {
        get { return self._moveMode }
    }

    let maxDurationInfSeconds: UInt = (13 * 60) /// seconds of the battery life

    public init(direction: MoveDirection, speedInCM: UInt, durationInSeconds: UInt) {
        self._direction = direction
        self._speed = speedInCM
        self._duration = durationInSeconds
        self._moveMode = MoveMode.MoveAtSpeedForSeconds(direction, speedInCM, durationInSeconds)
    }
    
    public init(direction: MoveDirection, speedInCM: UInt) {
        self._direction = direction
        self._speed = speedInCM
        self._duration = 0
        self._moveMode = MoveMode.MoveAtSpeed(direction, speedInCM)
    }

    public init(direction: MoveDirection, durationInSeconds: UInt) {
        self._direction = direction
        self._speed = 0
        self._duration = maxDurationInfSeconds
        self._moveMode = MoveMode.MoveForSeconds(direction, durationInSeconds)
    }
}
