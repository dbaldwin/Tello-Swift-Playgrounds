//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, turnRight(degree:), turnLeft(degree:))
_setupOneDroneEnv()
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
takeOff()
//#-editable-code Tap to enter code

//#-end-editable-code
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Great work!\nBy inputting a degree, you can make Tello turn to whichever direction you want it to.\n\n[**Next Page**](@next)",
    comment: "Changing the Course page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.turnLeft(degree: 90), [
        NSLocalizedString("Use `turnLeft(degree: 90)` to turn counterclockwise.", comment: "turnLeft(degree:) hint")]),
    (.turnRight(degree: 90), [
        NSLocalizedString("Use `turnRight( degree: 90)` to turn clockwise.", comment: "turnRight(degree:) hint")]),
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")])
]
PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)
//#-end-hidden-code
