//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(literal, show, array)
//#-code-completion(currentmodule, show)
//#-code-completion(description, show, "[Int]")
//#-code-completion(identifier, show, if, func, for, while, (, ), (), var, let, ., =, <, >, ==, !=, +=, +, -, >=, <=, true, false, swarm, tellos, &&, ||, !)

//#-code-completion(identifier, show, takeOff(), land())
//#-code-completion(identifier, show, flyUp(cm:), flyDown(cm:))
//#-code-completion(identifier, show, flyLeft(cm:), flyRight(cm:))
//#-code-completion(identifier, show, flyForward(cm:), flyBackward(cm:))
//#-code-completion(identifier, show, turnRight(degree:), turnLeft(degree:))
//#-code-completion(identifier, show, sync(seconds:))
//#-code-completion(identifier, show, transit(x:y:z:))
//#-code-completion(identifier, show, transit(x:y:z:pad1:pad2:))
//#-code-completion(identifier, show, flyLine(x:y:z:pad:))
//#-code-completion(identifier, show, scan(number:))
//#-code-completion(identifier, show, swarm, tellos)
_setupMultipleDronesEnv()
startMultipleDronesAssessor()
let swarm = TelloManager
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
 */
//#-editable-code Tap to enter code
swarm.scan(number: <#T##Int##Int#>)


//#-end-editable-code
//#-hidden-code
_cleanMultipleDroneEnv()
let success = NSLocalizedString(
    "### Well done!\nYou can now control multiple drones!\n\n[**Next Page**](@next)",
    comment: "Find all Tellos page success")

var expected: [Assessor.Assessment] = []

for _ in 0..<swarm.tellos.count {
    expected.append(
        (.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")])
    )
}
for _ in 0..<swarm.tellos.count {
    expected.append(
        (.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")])
    )
}

PlaygroundPage.current.assessmentStatus = checkMultipleDronesAssessment(expected:expected, success: success)
//#-end-hidden-code
