//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, flyLine(x:y:z:pad:))
//#-code-completion(identifier, show, getPadID(), getPadPos())
_setupOneDroneEnv(mon: true)
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 */
takeOff()
var padId = /*#-editable-code*/<#function#>/*#-end-editable-code*/
getPadPos()
//#-editable-code Tap to enter code.
flyLine(x: <#T##Int##Int#>, y: <#T##Int##Int#>, z: <#T##Int##Int#>, pad: padId)
//#-end-editable-code
getPadPos()
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Great job!\nYou have learned the flyLine command!\n\n[**Next Page**](@next)",
    comment: "TakeoffLand page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.getPadID, [NSLocalizedString("To get Pad ID of drone you need to use the `getPadID()` command.", comment: "getPadID hint")]),
    (.getPadPos, [NSLocalizedString("To get Pad position of drone you need to use the `getPadPos()` command.", comment: "getPadPos hint")]),
    (.flyLine(x: 30, y: 0, z: 100, pad: padId),
     [NSLocalizedString("To fly line you need to use the `flyLine(x: 30, y: 0, z: 100, pad: padId)` command.", comment: "flyLine(x:y:z:pad:) hint")]),
    (.getPadPos, [NSLocalizedString("To get Pad position of drone you need to use the `getPadPos()` command.", comment: "getPadPos hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]),
]

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
