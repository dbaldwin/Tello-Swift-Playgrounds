//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, flyForward(cm:), flyBackward(cm:))
//#-code-completion(identifier, show, flyLeft(cm:), flyRight(cm:))
_setupOneDroneEnv()
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
takeOff()
//#-editable-code Tap to enter code
flyRight(cm: <#T##UInt##UInt#>)



flyRight(cm: <#T##UInt##UInt#>)
//#-end-editable-code
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Congratulations!\nYou've secured the Space Station with the skills you've learned.\n\n[**Next Page**](@next)",
    comment: "Fly Around the Space Station page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.flyRight(cm: 100),   [NSLocalizedString("Use `flyRight(cm: 100)` to fly right.", comment: "flyRight(cm:) hint")]),
    (.flyForward(cm: 200), [NSLocalizedString("To fly forward you need to use `flyForward(cm: 200)`.", comment: "flyForward(cm:) hint1")]),
    (.flyLeft(cm: 200),    [NSLocalizedString("Use `flyLeft(cm: 200)` to fly left.", comment: "flyLeft(cm:) hint")]),
    (.flyBackward(cm: 200),[NSLocalizedString("To fly backward you need to use the `flyBackward(cm: 200)` command.", comment: "flyBackward(cm:) hint")]),
    (.flyRight(cm: 100),   [NSLocalizedString("Use `flyRight(cm: 100)` to fly right.", comment: "flyRight(cm:) hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")])
]
        
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
