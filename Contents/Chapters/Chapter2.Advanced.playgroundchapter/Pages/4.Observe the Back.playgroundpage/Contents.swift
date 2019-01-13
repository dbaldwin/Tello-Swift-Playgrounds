//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, turnRight(degree:), turnLeft(degree:))
//#-code-completion(identifier, show, flyCurve(x1:y1:z1:x2:y2:z2:))
_setupOneDroneEnv()
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
takeOff()
//#-editable-code Tap to enter code
flyCurve(x1: <#T##Int##Int#>, y1: <#T##Int##Int#>, z1: <#T##Int##Int#>, x2: <#T##Int##Int#>, y2: <#T##Int##Int#>, z2: <#T##Int##Int#>)
//#-end-editable-code
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Amazing!\nYou’ve learned a very complicated command, and now you are ready to fly to whichever place you want, in whatever way you like!\n\n[**Next Page**](@next)",
    comment: "Observe the Back page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.flyCurve(x1:100, y1:100, z1:0, x2:200, y2:0, z2:0),
     [NSLocalizedString("To fly a curve you need to use the `flyCurve(x1:100, y1:100, z1:0, x2:200, y2:0, z2:0)` command.", comment: "flyCurve(x1:, y1:, z1:, x2:, y2:, z2:) hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]),
]

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
