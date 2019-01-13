//
//  DronePuppet.swift
//  DronePuppet
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
 * Created by XIAOWEI WANG on 14/04/2018.
 * support@ryzerobotics.com
 *
 
 */
import Foundation

public class DronePuppet {
    private var _address: Data!
    private var _stringAddress: String = ""
    private var _port: UInt16 = 0
    private var _inetFamily: UInt8 = UInt8(AF_INET)
    
    private var _key: String!
    
    private var _lastCommandString: String = "command"
    private var _lastCommand: CommandFactory.Command = .command
    private var _lastResponse: String = ""
    
    private var _speed: UInt = 60
    private var _time:  UInt = 0
    private var _battery: UInt = 0
    private var _id     : Int  = -1
    private var _sn     : String  = "--"

    private var _timeoutSend: TimeInterval = 10
    private var _responseTimeout: TimeInterval = 50
    private var _timeoutWaitingForClose: TimeInterval = 30

    private var _socket : GCDAsyncUdpSocket!
    private var _executeQueue: DispatchQueue!
    private var _propertiesQueue: DispatchQueue!
    private var _executeSemaphore: DispatchSemaphore!
    private var _syncSemaphore: DispatchSemaphore!
    private let _isOnExecuteQueue = DispatchSpecificKey<()>()
    private let _isOnPropertiesQueue = DispatchSpecificKey<()>()

    init() {
        _key = "invalid"
    }
    init(id: Int, address: Data, socket: GCDAsyncUdpSocket) {
        _id        = id
        _address = address
        
        _socket    = socket

        (_stringAddress, _port, _inetFamily) = GCDAsyncUdpSocket.getHost(fromAddress: address)
        _key = String(format: "%@:%d", _stringAddress, _port)
        _executeQueue = DispatchQueue(label: _key + "PuppetExecuteQueue")
        _propertiesQueue = DispatchQueue(label: _key + "propertiesQueue")
        
        _executeQueue.setSpecific(key: _isOnExecuteQueue, value: ())
        _propertiesQueue.setSpecific(key: _isOnPropertiesQueue, value: ())

        _syncSemaphore = DispatchSemaphore(value: 0)
        _executeSemaphore = DispatchSemaphore(value: 0)
        _executeSemaphore.signal()
    }

    public var responseTimeout: TimeInterval {
        get {
            return synchronize { return _responseTimeout } as! TimeInterval
        }
        set {
            asynchronize { self._responseTimeout = newValue }
        }
    }

    var timeoutWaitingForClose: TimeInterval {
        get { return synchronize { return _timeoutWaitingForClose } as! TimeInterval }
        set {
            asynchronize { self._timeoutWaitingForClose = newValue }
        }
    }
    
    var lastCommand: CommandFactory.Command {
        get {
            return synchronize {
                return _lastCommand
                } as! CommandFactory.Command
        }
        set {
            asynchronize {
                self._lastCommand = newValue
            }
        }
    }
    
    var lastCommandString: String {
        get {
            return synchronize {
                return _lastCommandString
                } as! String
        }
        set {
            asynchronize {
                self._lastCommandString = newValue
            }
        }
    }
    
    private var _status: DroneStatus? = nil
    public var status: DroneStatus? {
        get {
            return synchronize {
                return _status
                } as? DroneStatus
        }
        set{
            asynchronize {
                self._status = newValue
            }
        }
    }

    public var lastResponse: String {
        get {
            return synchronize { return _lastResponse } as! String
        }
    }
    
    private func setLastResponse(response: String) {
        asynchronize {
            self._lastResponse = response
        }
    }

    var key: String {
        return self._key
    }
    
    public var stringAddress: String {
        return self._stringAddress
    }
    
    public var id: Int {
        get { return _id }
        set { _id = newValue }
    }
    
    public var sn: String {
        get { return _sn }
    }
    
    var mid: Int {
        get { return status?.marker.id ?? -1}
    }
    
    var speed: UInt {
        get { return synchronize { return _speed } as! UInt }
        set {
            asynchronize { self._speed = newValue }
        }
    }

    func clearResponse() {
        setLastResponse(response: "")
    }

    func notifyResponse(response: String) {
        
        asynchronize {
            if case .getSN(_) = self._lastCommand {
                self._sn = response
            }
            self._lastResponse = response
            self._syncSemaphore.signal()
            self._executeSemaphore.signal()
            DroneLog.info(String(format: "drone id: %d, response: %@, command: %@",self._id, response, self._lastCommandString)) //-debug-log
        }
    }

    private func waitResponse(seconds: TimeInterval) -> DispatchTimeoutResult {
        return _executeSemaphore.wait(timeout: .now() + seconds)
    }

    func sync(group: DispatchGroup, seconds: UInt, timeout: TimeInterval = 10) {
        group.enter()
        DroneLog.debug(String(format: "drone id: %d enter", self._id)) //-debug-log

        let syncQueue = DispatchQueue(label: String(format: "Drone%dSyncQueue", self._id))
        syncQueue.async {
            DroneLog.debug(String(format: "on syncQueue %d", self._id))
            let ret = self._syncSemaphore.wait(timeout: .now() +  timeout) == .success
            DroneLog.debug(String(format: "drone id: %d leave result: %@", self._id, ret ? "success" : "timeout")) //-debug-log
            group.leave()
        }
    }

    func ensureAllCommandsIssued(group: DispatchGroup) {
        group.enter()
        //-debug-log DroneLog.debug(String(format: "***Goodbye***", self._id)) 
        self.queueCommand(commandString: "command", command: .command)
        _executeQueue.async {
            DroneLog.debug(String(format: "on ensureQueue %d", self._id))
            _ = self.waitResponse(seconds: self._timeoutWaitingForClose)
            DroneLog.info(String(format: "***All commands were issued, drone id: %d***", self._id)) //-debug-log
            group.leave()
        }
    }

    func queueCommand(commandString: String, command: CommandFactory.Command) {
        _executeQueue.async {
            DroneLog.debug(String(format: "drone id: %d, queuing command: %@", self._id, commandString)) //-debug-log

            _ = self.waitResponse(seconds: self._responseTimeout)

            self.clearResponse()
            self.lastCommandString = commandString
            self.lastCommand = command
            let commandData = commandString.data(using: .utf8)!
            DroneLog.info(String(format: "drone id: %d, sending command: %@", self._id, commandString)) //-debug-log
            self._socket.send(commandData, toAddress: self._address, withTimeout: self._timeoutSend, tag: self._id)
        }
    }

    func synchronize(block: () -> Any?) -> Any? {
        var result : Any?
        if( DispatchQueue.getSpecific(key: _isOnPropertiesQueue) != nil) {
            result = block()
        } else {
            result = _propertiesQueue.sync(execute: block)
        }
        return result
    }

    func synchronize(block: () -> Void) {
        if( DispatchQueue.getSpecific(key: _isOnPropertiesQueue) != nil) {
            block()
        } else {
            _propertiesQueue.sync(execute: block)
        }
    }

    func asynchronize(block: @escaping () -> Void) {
        if( DispatchQueue.getSpecific(key: _isOnPropertiesQueue) != nil) {
            block()
        } else {
            _propertiesQueue.async(execute: block)
        }
    }
}

