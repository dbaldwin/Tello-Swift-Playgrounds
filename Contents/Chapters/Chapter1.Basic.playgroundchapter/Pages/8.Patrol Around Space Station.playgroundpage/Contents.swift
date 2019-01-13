//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:))
//#-code-completion(identifier, show, flyForward(cm:), flyBackward(cm:))
//#-code-completion(identifier, show, turnRight(degree:), turnLeft(degree:))
_setupOneDroneEnv()
startAssessor()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/
takeOff()
//#-editable-code Tap to enter code
turnRight(degree: <#T##Int##Int#>)

//#-end-editable-code
for i in 1...3 {
    //#-editable-code Tap to enter code

    //#-end-editable-code
}
//#-editable-code Tap to enter code

flyForward(cm: <#T##UInt##UInt#>)
turnLeft(degree: 90)
//#-end-editable-code
land()
//#-hidden-code
_cleanOneDroneEnv()
let success = NSLocalizedString(
    "### Impressive!\nYou’ve used a new method to complete the challenge.\n\n[**Next Page**](@next)",
    comment: "Patrol Around Space Station page success")

var expected: [Assessor.Assessment] = [
    (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]),
    (.turnRight(degree: 90), [
        NSLocalizedString("Use `turnRight( degree: 90)` to turn clockwise.", comment: "turnRight(degree:) hint")]),
    (.flyForward(cm: 90), [
        NSLocalizedString("To fly forward you need to use `flyForward(cm: 90)`.", comment: "flyForward(cm:) hint1")]),
]
for _ in 0..<3 {
    var a = Assessor.Assessment(
        (.turnLeft(degree: 90), [
            NSLocalizedString("Use `turnLeft(degree: 90)` to turn counterclockwise.", comment: "turnLeft(degree:) hint")
            ]
        )
    )
    expected.append(a)
    
    a = Assessor.Assessment(
        (.flyForward(cm: 180),[
            NSLocalizedString("To fly forward  you need to use `flyForward(cm: 180)`.", comment: "flyForward(cm:) hint1"),
            ]
        )
    )
    expected.append(a)
}
expected.append(
    (.turnLeft(degree: 90), [
        NSLocalizedString("Use `turnLeft(degree: 90)` to turn counterclockwise.", comment: "turnLeft(degree:) hint")
        ]
    )
)
expected.append(
    (.flyForward(cm: 90), [
        NSLocalizedString("To fly forward  you need to use `flyForward(cm: 90)`.", comment: "flyForward(cm:) hint1"),
        ]
    )
)

expected.append(
    (.turnLeft(degree: 90), [
        NSLocalizedString("Use `turnLeft(degree: 90)` to turn counterclockwise.", comment: "turnLeft(degree:) hint")
        ]
    )
)

expected.append(
(.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")])
)

PlaygroundPage.current.assessmentStatus = checkAssessment(expected:expected, success: success)

//#-end-hidden-code
