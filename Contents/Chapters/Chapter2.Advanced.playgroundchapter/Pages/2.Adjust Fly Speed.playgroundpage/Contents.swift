//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, flyForward(cm:), flyBackward(cm:))
//#-code-completion(identifier, show, turnRight(degree:), turnLeft(degree:))
//#-code-completion(identifier, show, setSpeed(cms:))

_setupOneDroneEnv()
startAssessor()
setSpeed(cms: 100)
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
takeOff()
flyForward(cm: 100)
turnRight(degree: 180)
//#-editable-code Tap to enter code
setSpeed(cms: <#T##UInt##UInt#>)
//#-end-editable-code
flyForward(cm: 100)
turnRight(degree: 180)
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Great job!\nYou’ve learned your first setter command!\n\n[**Next Page**](@next)",
    comment: "Adjust Fly Speed page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.flyForward(cm: 100), [NSLocalizedString("To fly forward you need to use the `flyForward(cm: 100)` command.", comment: "flyForward(cm:) hint")]),
    (.turnRight(degree: 180), [NSLocalizedString("Use `turnRight(degree: 180)` to turn clockwise.", comment: "turnRight(degree:) hint")]),
    (.setSpeed(cms: 50), [NSLocalizedString("To set speed you need to use the `setSpeed(cms: 50)` command.", comment: "setSpeed(cms:) hint")]),
    (.flyForward(cm: 100), [NSLocalizedString("To fly forward you need to use the `flyForward(cm: 100)` command.", comment: "flyForward(cm:) hint")]),
    (.turnRight(degree: 180), [NSLocalizedString("Use `turnRight(degree: 180)` to turn clockwise.", comment: "turnRight(degree:) hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]),
]

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
