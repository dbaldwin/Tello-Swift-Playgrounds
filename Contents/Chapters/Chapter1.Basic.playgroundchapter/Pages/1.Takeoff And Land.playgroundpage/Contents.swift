//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))

_setupOneDroneEnv()
startAssessor()

//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
//#-editable-code Tap to enter code.

//#-end-editable-code
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Congratulations!\nYou‘ve written your first command to control Tello!\n\n[**Next Page**](@next)",
    comment: "TakeoffLand page success")
let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]),
]
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
