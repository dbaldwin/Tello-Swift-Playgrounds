//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, flyLine(x:y:z:))
_setupOneDroneEnv()
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
takeOff()
//#-editable-code Tap to enter code
flyLine(x: <#T##Int##Int#>, y: <#T##Int##Int#>, z: <#T##Int##Int#>)
//#-end-editable-code
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Great job!\nYou’ve learned the most efficient way to control Tello. There is more to come, keep up the good work!\n\n[**Next Page**](@next)",
    comment: "Observe the Front page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.flyLine(x: 100, y: 100, z: 0, pad: 100),
     [NSLocalizedString("To fly a line you need to use the `flyLine(x: 100, y: 100, z: 0)` command.", comment: "flyLine(x:, y:, z:) hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]),
]

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
