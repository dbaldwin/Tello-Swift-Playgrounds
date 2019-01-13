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
swarm.sync(seconds: /*#-editable-code*/10/*#-end-editable-code*/)
for i in 1...4 {
    //#-editable-code Tap to enter code
    //#-end-editable-code
}
swarm.tellos.land()
//#-hidden-code
_cleanMultipleDroneEnv()
let success = NSLocalizedString(
    "### Congratulations!\nYou have successfully commanded a swarm of drones to fly on Mission Pads！\n\n[**Next Page**](@next)",
    comment: "Form A Guarding Fence page success")
let telloCount = swarm.tellos.count
var expected: [Assessor.Assessment] = []

for _ in 0..<telloCount {
    expected.append(
        (.takeOff,
         [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]))
}
for _ in 0..<telloCount {
    expected.append(
        (.flyDown(cm: 50),
         [NSLocalizedString("To fly down you need to use the `flyDown(cm: 50)` command.", comment: "flyDown(cm:) hint")]
    ))
}

for i in 1...4 {
    expected.append(
        (.transit(x: 100, y: 0, z: 100, pad1: -2, pad2: -1),
         [NSLocalizedString("To transit to another Mission Pad you need to use the `transit(x: 100, y: 0, z: 100, pad1: -2, pad2: -1)` command.", comment: "transit(x:y:z:pad1:pad2) hint")])
    )
}

for _ in 0..<telloCount {
    expected.append((.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]))
}

PlaygroundPage.current.assessmentStatus = checkMultipleDronesAssessment(expected:expected, success: success)
//#-end-hidden-code
