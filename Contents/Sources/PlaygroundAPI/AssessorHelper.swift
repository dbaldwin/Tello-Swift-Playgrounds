//
//  AssessorHelper.swift
//  AssessorHelper
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
import PlaygroundSupport

/// Starts collecting action to check assessment

public func startMultipleDronesAssessor() {
    TelloManager.assessor = Assessor()
}

public func startAssessor() {
    Tello.assessor = Assessor()
    Tello.assessor?.drone = Tello
}

/// Check if expected actions have been made
public func checkAssessment(expected expectedActions: [Assessor.Assessment], success: String?)
    -> PlaygroundPage.AssessmentStatus? {
        return Tello.assessor?.check(expected: expectedActions, success: success)
}

public func checkMultipleDronesAssessment(expected expectedActions: [Assessor.Assessment], success: String?)
    -> PlaygroundPage.AssessmentStatus? {
        return TelloManager.assessor?.check(expected: expectedActions, success: success)
}
