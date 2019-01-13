//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, flyUp(cm:), flyDown(cm:))
_setupOneDroneEnv()
startAssessor()

//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
takeOff()
//#-editable-code Tap to enter code
flyUp(cm: <#T##UInt##UInt#>)
flyDown(cm: <#T##UInt##UInt#>)
//#-end-editable-code
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Good job!\nYou've written more complex code, and you've learned that the order of the code is important.\n\n[**Next Page**](@next)",
    comment: "Up And Down page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.flyUp(cm: 100), [NSLocalizedString("To fly up you need to use the `flyUp(cm: 100)` command.", comment: "flyUp(cm:) hint")]),
    (.flyDown(cm: 100), [NSLocalizedString("To fly down you need to use the `flyDown(cm: 100)` command.", comment: "flyDown(cm:) hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]),
]

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
