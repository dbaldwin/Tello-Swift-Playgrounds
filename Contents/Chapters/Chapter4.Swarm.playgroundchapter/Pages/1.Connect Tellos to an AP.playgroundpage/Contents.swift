//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, connectAP(ssid:password:))

_setupOneDroneEnv()
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
//#-editable-code Tap to enter code.
connectAP(ssid: <#T##String##String#>, password: <#T##String##String#>)
//#-end-editable-code

//#-hidden-code
wait(seconds: 3)
let success = NSLocalizedString(
    "### Congratulations!\nYou’ve taken the first step toward swarm control!\n\n[**Next Page**](@next)",
    comment: "Connect Tellos to an AP page success")
let expected: [Assessor.Assessment] = [
    (.connectAP(ssid: "Tello_Nest", password: "tellotello"),
     [NSLocalizedString("Use `connectAP(ssid: String, password: String)` to connect Tello to a designated AP.", comment: "connectAP(ssid:password:) hint")]),
]
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
PlaygroundPage.current.needsIndefiniteExecution = false
//#-end-hidden-code
