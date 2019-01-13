//
//  Log.swift
//  Log
//
/*
 
 * @version 1.0
 
 * @date Aug 2018
 
 *
 
 *
 
 * @Copyright (c) 2018 Ryze Tech
 
 *
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 
 * of this software and associated documentation files (the "Software"), to deal
 
 * in the Software without restriction, including without limitation the rights
 
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 
 * copies of the Software, and to permit persons to whom the Software is
 
 * furnished to do so, subject to the following conditions:
 
 *
 
 * The above copyright notice and this permission notice shall be included in
 
 * all copies or substantial portions of the Software.
 
 *
 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 
 * SOFTWARE.
 
 * *
 * Created by XIAOWEI WANG on 12/08/2018.
 * support@ryzerobotics.com
 *
 
 */
import Foundation
import Dispatch


public let logger = SwiftyBeaver.self

public func getLogger() -> SwiftyBeaver.Type {
    return logger
}

public func initLogger(level: SwiftyBeaver.Level = .debug ) {
    let file = FileDestination()  // log to default swiftybeaver.log file
    let console = ConsoleDestination()  // log to Xcode Console
    logger.addDestination(file)
    logger.addDestination(console)
    file.minLevel = level
    console.minLevel = level
}

public func uploadLogs(remoteURL: String, timeout: TimeInterval = 5) -> FileUploader {
    let uploader = FileUploader()
    let logFileURL = (logger.destinations.first as! FileDestination).logFileURL!
    while !FileManager.default.fileExists(atPath: logFileURL.relativePath) {
        logger.debug("----FORCING TO FLUSH----")
        sleep(1)
    }
    _ = uploader.uploadFile(path: logFileURL, remoteURL: remoteURL)
    return uploader
}

public class DroneLog {
    // MARK: Levels
    
    public class func verbose( _ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        logger.verbose(message, path, function, line: line)
    }
    
    public class func debug( _ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        logger.debug(message, path, function, line: line)
    }
    
    public class func info( _ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        logger.info(message, path, function, line: line)
    }
    
    public class func warning( _ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        logger.warning(message, path, function, line: line)
    }
    
    public class func error( _ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        logger.error(message, path, function, line: line)
    }
}

public class GCDLog {
    // MARK: Levels

    public class func verbose( _ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        logger.verbose(message, path, function, line: line)
    }
    
    public class func debug( _ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        logger.debug(message, path, function, line: line)
    }
    
    public class func info( _ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        logger.info(message, path, function, line: line)
    }
    
    public class func warning( _ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        logger.warning(message, path, function, line: line)
    }
    
    public class func error( _ message: @autoclosure () -> Any, _ path: String = #file, _ function: String = #function, line: Int = #line) {
        logger.error(message, path, function, line: line)
    }
}
