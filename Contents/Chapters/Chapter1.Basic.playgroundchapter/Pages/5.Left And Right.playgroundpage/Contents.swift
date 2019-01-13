//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, flyLeft(cm:), flyRight(cm:))
_setupOneDroneEnv()
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
takeOff()
//#-editable-code Tap to enter code
flyLeft(cm: <#T##UInt##UInt#>)
//#-end-editable-code
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Great job!\nYou have learned most of the basic skills to fly Tello to wherever you want.\n\n[**Next Page**](@next)",
    comment: "Left And Right page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.flyLeft(cm: 100),    [NSLocalizedString("Use `flyLeft(cm: 200)` to fly left.", comment: "flyLeft(cm:) hint")]),
    (.flyRight(cm: 100),   [NSLocalizedString("Use `flyRight(cm: 100)` to fly right.", comment: "flyRight(cm:) hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")])
]

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
