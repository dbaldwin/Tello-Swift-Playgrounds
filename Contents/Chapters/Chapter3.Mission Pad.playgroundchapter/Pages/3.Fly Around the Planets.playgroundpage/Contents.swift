//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, flyLine(x:y:z:pad:))
//#-code-completion(identifier, show, getPadID(), getPadPos())
//#-code-completion(identifier, show, padId)
_setupOneDroneEnv(mon: true)
startAssessor()

//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 */
takeOff()
var padId = /*#-editable-code*/<#function#>/*#-end-editable-code*/
//#-editable-code Tap to enter code
flyLine(x: <#T##Int##Int#>, y: <#T##Int##Int#>, z: <#T##Int##Int#>, pad: <#T##Int##Int#>)
flyLine(x: <#T##Int##Int#>, y: <#T##Int##Int#>, z: <#T##Int##Int#>, pad: <#T##Int##Int#>)
flyLine(x: <#T##Int##Int#>, y: <#T##Int##Int#>, z: <#T##Int##Int#>, pad: <#T##Int##Int#>)
flyLine(x: <#T##Int##Int#>, y: <#T##Int##Int#>, z: <#T##Int##Int#>, pad: <#T##Int##Int#>)
//#-end-editable-code
flyLine(x: 0, y: 0, z: 100, pad: /*#-editable-code*/<#T##Int##Int#>/*#-end-editable-code*/)
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Congratulations!\nYou’ve used a new way to fly in a square. With the Mission Pad ID, you can fly to it with much higher accuracy!\n\n[**Next Page**](@next)",
    comment: "Fly Around the Planets page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.getPadID, [NSLocalizedString("To get Pad ID of drone you need to use the `getPadID()` command.", comment: "getPadID hint")]),
    (.flyLine(x: -30, y: 30, z: 100, pad: padId),
     [NSLocalizedString("To fly line you need to use the `flyLine(x: -30, y: 30, z: 100, pad: padId)` command.", comment: "flyLine(x:y:z:pad:) hint")]),
    (.flyLine(x: -30, y: -30, z: 100, pad: padId),
     [NSLocalizedString("To fly line you need to use the `flyLine(x: -30, y: -30, z: 100, pad: padId)` command.", comment: "flyLine(x:y:z:pad:) hint")]),
    (.flyLine(x: 30, y: -30, z: 100, pad: padId),
     [NSLocalizedString("To fly line you need to use the `flyLine(x: 30, y: -30, z: 100, pad: padId)` command.", comment: "flyLine(x:y:z:pad:) hint")]),
    (.flyLine(x: 30, y: 30, z: 100, pad: padId),
     [NSLocalizedString("To fly line you need to use the `flyLine(x: 30, y: 30, z: 100, pad: padId)` command.", comment: "flyLine(x:y:z:pad:) hint")]),

    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]),
]

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
