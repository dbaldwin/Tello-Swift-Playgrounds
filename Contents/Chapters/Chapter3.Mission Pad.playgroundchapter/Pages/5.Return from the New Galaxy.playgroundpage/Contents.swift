//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, getPadID(), .)
//#-code-completion(identifier, show, transit(x:y:z:pad1:pad2:), .)
_setupOneDroneEnv(mon: true)
startAssessor()

//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 */
takeOff()
//#-editable-code Tap to enter code.

//#-end-editable-code
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Good job!\nYou now know how to command Tello to jump in a network that is formed by the Mission Pads!\n\n[**Next Page**](@next)",
    comment: "Return from the New Galaxy page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.getPadID, [NSLocalizedString("To get Pad ID of drone you need to use the `getPadID()` command.", comment: "getPadID hint")]),
    (.transit(x: 100, y: 0, z: 100, pad1: 2, pad2: 1),
     [NSLocalizedString("To transit to another Mission Pad you need to use the `transit(x: 100, y: 0, z: 100, pad1: 2, pad2: 1)` command.", comment: "transit(x:y:z:pad1:pad2) hint")]),
    (.getPadID, [NSLocalizedString("To get Pad ID of drone you need to use the `getPadID()` command.", comment: "getPadID hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]),
]

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
