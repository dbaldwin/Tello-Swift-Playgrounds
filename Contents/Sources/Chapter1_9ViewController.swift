//
//  Chapter1_9ViewController.swift
//  Chapter1_9ViewController
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

@objc(Chapter1_9ViewController1)
class Chapter1_9ViewController1 : UIViewController {
    
    @IBOutlet weak var imageFlyTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageFlyLeftConstraint: NSLayoutConstraint!
    
    var backgroundImage: UIImageView!
    
    @IBOutlet weak var imageStay: UIImageView!
    @IBOutlet weak var imageFly: UIImageView!
    
    var aiPoints: [UIView]! = [UIView]()
    
    var imageStayTop: CGFloat!
    var imageStayLeft: CGFloat!

    var animation: EAAnimationFuture!
    var scaledTransform = CGAffineTransform.identity
    var scaledAndRotatedTransform = CGAffineTransform.identity
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        backgroundImage = UIImageView(image: UIImage(named: "course_spacebg_landscape"))
        backgroundImage.frame = self.view.frame
        self.view.insertSubview(backgroundImage, at: 0)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    weak var chain: EAAnimationFuture?
    
    var toPoint1 : CGPoint!
    var posPoints : [CGPoint] = [CGPoint]()
    
    var _droneObject: DroneModel!
    override func viewDidAppear(_ animated: Bool) {
        for i in 1..<10 {
            aiPoints.append(self.view.viewWithTag(i)!)
        }
        
        for i in 0..<(aiPoints.count-1) {
            let ap1 = aiPoints[i]
            let ap2 = aiPoints[i + 1]
            let posPoint = CGPoint(
                x: ap2.frame.origin.x -  ap1.frame.origin.x,
                y: ap2.frame.origin.y -  ap1.frame.origin.y // - center + delta
            )
            posPoints.append(posPoint)
        }
        let ap1 = aiPoints.last!
        let ap2 = aiPoints.first!
        let posPoint = CGPoint(
            x: ap2.frame.origin.x -  ap1.frame.origin.x,
            y: ap2.frame.origin.y -  ap1.frame.origin.y // - center + delta
        )
        posPoints.append(posPoint)
        
        _droneObject = DroneModel(contentView: self.view, stayAndFlyImage: [imageStay, imageFly], topAndLeftCOntraints: [imageFlyTopConstraint, imageFlyLeftConstraint], points: posPoints)
        
        //animation3()
    }
    
    
    @IBAction func moveNext(_ sender: Any) {
        _ = _droneObject.moveToNext()
    }
    
    @IBAction func onTakeOff(_ sender: Any) {
        _ = _droneObject.takeOff()
    }
    
    @IBAction func land(_ sender: Any) {
        _ = _droneObject.land()
    }
    
    @IBAction func onTurnLeft(_ sender: Any) {
        _ = _droneObject.turnLeft(degree: 90)
        /*
         chain = UIView.animateAndChain(withDuration: 2.0, delay: 0.0, options: [], animations: {
         self.imageStay.transform = self.turnLeft(origin: self.scaledAndRotatedTransform)
         self.view.layoutIfNeeded()
         
         }, completion: nil)*/
    }
    
    @IBAction func onTurnRight(_ sender: Any) {
        _ = _droneObject.turnRight(degree: 90)
        /*
         chain = UIView.animateAndChain(withDuration: 2.0, delay: 0.0, options: [], animations: {
         
         self.imageStay.transform = self.turnRight(origin: self.scaledAndRotatedTransform)
         self.view.layoutIfNeeded()
         
         }, completion: nil)*/
    }
}
