//
//  TestLayoutController.swift
//  LiveViewTestApp
//
//  Created by XIAOWEI WANG on 2018/8/27.
//

import UIKit
import PlaygroundSupport

@objc(TestLayoutController)
public class TestLayoutController: UIViewController, PlaygroundLiveViewSafeAreaContainer {

    fileprivate (set) var liveViewConnectionOpened = false
    
    @IBOutlet weak var imageFlyTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageFlyLeftConstraint: NSLayoutConstraint!
    
    var backgroundImage: UIImageView!
    
    @IBOutlet weak var imageStay: UIImageView!
    @IBOutlet weak var imageFly: UIImageView!
    @IBOutlet weak var bpBattery: UIProgressView!
    @IBOutlet weak var lbBattery: UILabel!
    
    var aiPoints: [UIView]! = [UIView]()
    
    var imageStayTop: CGFloat!
    var imageStayLeft: CGFloat!
    
    var animation: EAAnimationFuture!
    var scaledTransform = CGAffineTransform.identity
    var scaledAndRotatedTransform = CGAffineTransform.identity
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        backgroundImage = UIImageView(image: UIImage(named: "course_spacebg_landscape"))
        backgroundImage.frame = self.view.frame
        self.view.insertSubview(backgroundImage, at: 0)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
    }
    
    weak var chain: EAAnimationFuture?
    
    var toPoint1 : CGPoint!
    var posPoints : [CGPoint] = [CGPoint]()
    
    var _droneObject: DroneModel!
    override public func viewDidAppear(_ animated: Bool) {
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
    
    func takeOff() {
        DroneLog.debug("_droneObject.takeOff()")
        _ = _droneObject.takeOff()
    }
    
    func land() {
        _ = _droneObject.land()
    }
    
    func turnLeft() {
        _ = _droneObject.turnLeft(degree: 90)
    }
    
    func turnRight() {
        _ = _droneObject.turnRight(degree: 90)
    }
    
    func moveToNext() {
        _ = _droneObject.moveToNext()
    }
}

extension TestLayoutController: PlaygroundLiveViewMessageHandler {
    // Implement this method to be notified when the live view message connection is opened.
    // The connection will be opened when the process running Contents.swift starts running and listening for messages.
    final public func liveViewMessageConnectionOpened() {
        liveViewConnectionOpened = true
        DroneLog.debug("liveViewMessageConnectionOpened")
        //updateContent()
    }
    
    // Implement this method to be notified when the live view message connection is closed.
    // The connection will be closed when the process running Contents.swift exits and is no longer listening for messages.
    // This happens when the user's code naturally finishes running, if the user presses Stop, or if there is a crash.
    final public func liveViewMessageConnectionClosed() {
        liveViewConnectionOpened = false
        DroneLog.debug("liveViewMessageConnectionClosed")
    }
    
    // Implement this method to receive messages sent from the process running Contents.swift.
    // This method is *required* by the PlaygroundLiveViewMessageHandler protocol.
    // Use this method to decode any messages sent as PlaygroundValue values and respond accordingly.
    public func receive(_ message: PlaygroundValue) {
        lbBattery.text = "receive(_ message: PlaygroundValue)"
        guard case let .dictionary(command) = message else {
            DroneLog.debug("dictionary not avaiable")
            return
        }
        
        if case let .string(action)? = command["action"] {
            DroneLog.debug("action: ", action)
            lbBattery.text! += action
            switch action {
            case "takeoff":
                self.takeOff()
            case "land":
                self.land()
            case "turnLeft":
                self.turnLeft()
            case "turnRight":
                self.turnRight()
            case "flyForward":
                self.moveToNext()
            case "command":
                break
            default:
                break
            }
        } else {
            DroneLog.debug("action not avaiable")
        }
    }
    
    func send(event: String) {
        if liveViewConnectionOpened {
            //send(event: event.marshal())
        }
    }
}
