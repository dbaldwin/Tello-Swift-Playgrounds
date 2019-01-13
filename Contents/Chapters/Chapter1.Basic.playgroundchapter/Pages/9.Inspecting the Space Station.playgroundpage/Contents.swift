//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, flyUp(cm:), flyDown(cm:))
//#-code-completion(identifier, show, flyForward(cm:), flyBackward(cm:))
//#-code-completion(identifier, show, turnRight(degree:), turnLeft(degree:))
_setupOneDroneEnv()
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
takeOff()
//#-editable-code Tap to enter code
turnRight(degree: 90)
flyForward(cm: 90)
turnLeft(degree: 90)
flyForward(cm: 180)




flyForward(cm: <#T##UInt##UInt#>)
turnLeft(degree: <#T##Int##Int#>)
//#-end-editable-code
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Amazing!\nYou know what, the pattern you just flew is widely used in aerial surveillance, aerial 3D modeling photography, and drone agricultural irrigation.\n\n[**Next Page**](@next)",
    comment: "Inspecting the Space Station page success")

let expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    // ============= ============= \\
    (.turnRight(degree: 90), [
        NSLocalizedString("Use `turnRight(degree: 90)` to turn clockwise.", comment: "turnRight(degree:) hint")]),
    (.flyForward(cm: 90), [
        NSLocalizedString("To fly forward  you need to use `flyForward(cm: 90)`.", comment: "flyForward(cm:) hint1")]),
    (.turnLeft(degree: 90), [
        NSLocalizedString("Use `turnLeft(degree: 90)` to turn counterclockwise.", comment: "turnLeft(degree:) hint")]),
    // ============= ============= \\
    (.flyForward(cm: 180), [
        NSLocalizedString("To fly forward  you need to use `flyForward(cm: 180)`.", comment: "flyForward(cm:) hint1")]),
    (.turnLeft(degree: 90), [
        NSLocalizedString("Use `turnLeft(degree: 90)` to turn counterclockwise.", comment: "turnLeft(degree:) hint")]),
    (.flyForward(cm: 60), [
        NSLocalizedString("To fly forward  you need to use `flyForward(cm: 60)`.", comment: "flyForward(cm:) hint1")]),
    // ============= ============= \\
    (.turnLeft(degree: 90), [
        NSLocalizedString("Use `turnLeft(degree: 90)` to turn counterclockwise.", comment: "turnLeft(degree:) hint")]),
    (.flyForward(cm: 180), [
        NSLocalizedString("To fly forward  you need to use `flyForward(cm: 180)`.", comment: "flyForward(cm:) hint1")]),
    (.turnRight(degree: 90), [
        NSLocalizedString("Use `turnRight(degree: 90)` to turn clockwise.", comment: "turnRight(degree:) hint")]),
    // ============= ============= \\
    (.flyForward(cm: 60), [
        NSLocalizedString("To fly forward  you need to use `flyForward(cm: 60)`.", comment: "flyForward(cm:) hint1")]),
    (.turnRight(degree: 90), [
        NSLocalizedString("Use `turnRight(degree: 90)` to turn clockwise.", comment: "turnRight(degree:) hint")]),
    (.flyForward(cm: 180), [
        NSLocalizedString("To fly forward  you need to use `flyForward(cm: 180)`.", comment: "flyForward(cm:) hint1")]),
    // ============= ============= \\
    (.turnLeft(degree: 90), [
        NSLocalizedString("Use `turnLeft(degree: 90)` to turn counterclockwise.", comment: "turnLeft(degree:) hint")]),
    (.flyForward(cm: 60), [
       NSLocalizedString("To fly forward you need to use `flyForward(cm: 60)`.", comment: "flyForward(cm:) hint1"),
        ]),
    (.turnLeft(degree: 90), [
        NSLocalizedString("Use `turnLeft(degree: 90)` to turn counterclockwise.", comment: "turnLeft(degree:) hint")]),
    // ============= ============= \\

    (.flyForward(cm: 180), [
        NSLocalizedString("To fly forward  you need to use `flyForward(cm: 180)`.", comment: "flyForward(cm:) hint1")]),
    (.turnLeft(degree: 90), [
        NSLocalizedString("Use `turnLeft(degree: 90)` to turn counterclockwise.", comment: "turnLeft(degree:) hint")]),
    (.flyForward(cm: 90), [
        NSLocalizedString("To fly forward  you need to use `flyForward(cm: 90)`.", comment: "flyForward(cm:) hint1")]),
    
    (.turnLeft(degree: 90), [
        NSLocalizedString("Use `turnLeft(degree: 90)` to turn counterclockwise.", comment: "turnLeft(degree:) hint")]),
    
    (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")])
]

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)

//#-end-hidden-code
