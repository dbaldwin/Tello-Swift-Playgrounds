//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:), .)
//#-code-completion(identifier, show, getHeight())
//#-code-completion(identifier, show, flyCurve(x1:y1:z1:x2:y2:z2:), .)
_setupOneDroneEnv()
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
takeOff()
//#-editable-code Tap to enter code.
flyCurve(x1: <#T##Int##Int#>, y1: <#T##Int##Int#>, z1: <#T##Int##Int#>, x2: <#T##Int##Int#>, y2: <#T##Int##Int#>, z2: <#T##Int##Int#>)


//#-end-editable-code
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Congratulations!\nYou’ve managed to get the height data we need, and return to the Space Station safely!\n\n[**Next Page**](@next)",
    comment: "Full Observation page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.flyCurve(x1: 13, y1: 0, z1: 50, x2: 100, y2: 0, z2: 100),
     [NSLocalizedString("To fly a curve you need to use the `flyCurve(x1:13, y1: 0, z1: 50, x2: 100, y2: 0, z2: 100)` command.", comment: "flyCurve(x1:, y1:, z1:, x2:, y2:, z2:) hint")]),
    (.getHeight, [NSLocalizedString("To get height you need to use the `getHeight()` command.", comment: "getHeight hint")]),
    (.flyCurve(x1: 87, y1: 0, z1: -50, x2: 100, y2: 0, z2: -100),
     [NSLocalizedString("To fly a curve you need to use the `flyCurve(x1: 87, y1: 0, z1: -50, x2: 100, y2: 0, z2: -100)` command.", comment: "flyCurve(x1:, y1:, z1:, x2:, y2:, z2:) hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]),
]

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
