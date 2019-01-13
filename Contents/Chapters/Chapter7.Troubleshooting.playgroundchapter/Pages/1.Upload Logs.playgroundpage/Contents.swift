//#-hidden-code
import UIKit
import PlaygroundSupport

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, takeOff(), land(), wait(seconds:), go(x: , y: , z: , speed: ))
//_setup()
PlaygroundPage.current.needsIndefiniteExecution = true
initLogger()
//#-end-hidden-code
/*:#localized(key: "FirstProseBlock")
*/

//#-editable-code Tap to enter code.
getLogger().debug("Uploading Logs")
uploadLogs(remoteURL: "http://192.168.3.87:8000/abc.txt")
//#-end-editable-code

//#-hidden-code
PlaygroundPage.current.needsIndefiniteExecution = false
//#-end-hidden-code
