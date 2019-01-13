//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, flyForward(cm:), flyBackward(cm:))
_setupOneDroneEnv()
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
takeOff()
//#-editable-code Tap to enter code
flyForward(cm: <#T##UInt##UInt#> )


//#-end-editable-code
land()

//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Well Done!\nTello executed the commands you wrote and did exactly what you asked.\n\n[**Next Page**](@next)",
    comment: "Forward And Backward page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.flyForward(cm: 100), [NSLocalizedString("To fly forward you need to use the `flyForward(cm: 100)` command.", comment: "flyForward(cm:) hint")]),
    (.flyBackward(cm: 100), [NSLocalizedString("To fly backward you need to use the `flyBackward(cm: 100)` command.", comment: "flyBackward(cm:) hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]),
]

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
