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
swarm.scan(number: /*#-editable-code*/<#T##Int##Int#>/*#-end-editable-code*/)
//#-editable-code Set up Tellos initial height
//#-end-editable-code
swarm.sync(seconds: /*#-editable-code*/10/*#-end-editable-code*/)
for i in 1...4 {
    //#-editable-code Make the 1st half of flying
    //#-end-editable-code
    swarm.sync(seconds: /*#-editable-code*/10/*#-end-editable-code*/)
    //#-editable-code Make the 2nd half of flying
    //#-end-editable-code
    swarm.sync(seconds: /*#-editable-code*/10/*#-end-editable-code*/)
}
//#-editable-code Make Tellos hover at the same height
//#-end-editable-code
swarm.sync(seconds: /*#-editable-code*/10/*#-end-editable-code*/)
swarm.tellos.land()
//#-hidden-code
_cleanMultipleDroneEnv()
let success = NSLocalizedString(
    "### Congratulations!\nYou just made multiple drones dance!\n\n[**Next Page**](@next)",
    comment: "3.Control the Flow page success")

var expected: [Assessor.Assessment] = []

for _ in 0..<swarm.tellos.count {
    expected.append((.takeOff, [NSLocalizedString("To take off you need to use the `takeOff()` command.", comment: "takeOff hint")]))
}

expected.append((
    .flyUp(cm: 25),
    [NSLocalizedString("To fly up you need to use the `flyUp(cm: 50)` command.", comment: "flyUp(cm:) hint")]
))

expected.append((
    .flyDown(cm: 25),
    [NSLocalizedString("To fly down you need to use the `flyDown(cm: 50)` command.", comment: "flyDown(cm:) hint")]
))

for _ in 1...3 {
    expected.append((.flyDown(cm: 50),
                     [NSLocalizedString("To fly down you need to use the `flyDown(cm: 50)` command.", comment: "flyDown(cm:) hint")]
    ))
    expected.append((.flyUp(cm: 50),
                     [NSLocalizedString("To fly up you need to use the `flyUp(cm: 50)` command.", comment: "flyUp(cm:) hint")]
    ))

    expected.append((.flyUp(cm: 50),
                     [NSLocalizedString("To fly up you need to use the `flyUp(cm: 50)` command.", comment: "flyUp(cm:) hint")]
    ))
    expected.append((.flyDown(cm: 50),
                     [NSLocalizedString("To fly down you need to use the `flyDown(cm: 50)` command.", comment: "flyDown(cm:) hint")]
    ))
}

expected.append((
    .flyDown(cm: 25),
    [NSLocalizedString("To fly down you need to use the `flyDown(cm: 50)` command.", comment: "flyDown(cm:) hint")]
))

expected.append((
    .flyUp(cm: 25),
    [NSLocalizedString("To fly up you need to use the `flyUp(cm: 50)` command.", comment: "flyUp(cm:) hint")]
))

for _ in 0..<swarm.tellos.count {
    expected.append((.land, [NSLocalizedString("To land you need to use the `land()` command.", comment: "land hint")]))
}

PlaygroundPage.current.assessmentStatus = checkMultipleDronesAssessment(expected:expected, success: success)
//#-end-hidden-code
