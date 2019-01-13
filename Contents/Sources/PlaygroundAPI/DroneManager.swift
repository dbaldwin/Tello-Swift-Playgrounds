//
//  DroneManager.swift
//  DroneManager
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

public enum DroneNo: Int {
    case All      = 0xffffffff
    case First    = 1
    case Second   = 2
    case Third    = 3
    case Fourth   = 4
    case Fiveth   = 5
    case Sixth    = 6
    case Seventh  = 7
    case Eighth   = 8
}

extension Array where Element == Drone {
    
    @discardableResult
    public func mon() -> Int {
        for drone in self {
            _ = drone.mon()
        }
        return count
    }
    
    @discardableResult
    public func mdirection(direction: Int) -> Int {
        for drone in self {
            _ = drone.mdirection(direction: direction)
        }
        return count
    }
    
    @discardableResult
    public func takeOff() -> Int {
        for drone in self {
            _ = drone.takeOff()
        }
        return count
    }
    
    @discardableResult
    public func getSN() -> Int {
        for drone in self {
            _ = drone.getSN()
        }
        return count
    }
    
    @discardableResult
    public func land() -> Int {
        for drone in self {
            _ = drone.land()
        }
        return count
    }
    
    @discardableResult
    public func flyUp(cm: UInt) -> Int {
        for drone in self {
            _ = drone.flyUp(cm: cm)
        }
        return count
    }
    
    @discardableResult
    public func flyDown(cm: UInt) -> Int {
        for drone in self {
            _ = drone.flyDown(cm: cm)
        }
        return count
    }
    
    @discardableResult
    public func flyLeft(cm: UInt) -> Int {
        for drone in self {
            _ = drone.flyLeft(cm: cm)
        }
        return count
    }
    
    @discardableResult
    public func flyRight(cm: UInt) -> Int {
        for drone in self {
            _ = drone.flyRight(cm: cm)
        }
        return count
    }
    
    @discardableResult
    public func flyForward(cm: UInt) -> Int {
        for drone in self {
            _ = drone.flyForward(cm: cm)
        }
        return count
    }
    
    @discardableResult
    public func flyBackward(cm: UInt) -> Int {
        for drone in self {
            _ = drone.flyBackward(cm: cm)
        }
        return count
    }
    
    @discardableResult
    public func turnLeft(degree: Int) -> Int {
        for drone in self {
            _ = drone.turnLeft(degree: degree)
        }
        return count
    }
    
    @discardableResult
    public func turnRight(degree: Int) -> Int {
        for drone in self {
            _ = drone.turnRight(degree: degree)
        }
        return count
    }
    
    @discardableResult
    public func go(x: Int, y: Int, z: Int, speed: UInt) -> Int {
        for drone in self {
            let speed = drone.getSpeed()
            _ = drone.go(x: x, y: y, z: z, speed: speed, marker: "")
        }
        return count
    }

    @discardableResult
    public func go(x: Int, y: Int, z: Int, speed: UInt, marker: String) -> Int {
        for drone in self {
            let speed = drone.getSpeed()
            _ = drone.go(x: x, y: y, z: z, speed: speed, marker: marker)
        }
        return count
    }

    @discardableResult
    private func transit(x: Int, y: Int, z: Int, pad1: Int, pad2: Int) -> Int {
        for drone in self{
            let speed = drone.getSpeed()
            let m1 = String(format: "m%d", pad1)
            let m2 = String(format: "m%d", pad2)
            _ = drone.jump(x: x, y: y, z: z, speed: speed, yaw: 0, marker1: m1, marker2: m2)
            TelloManager.assessor?.add(action: .transit(x: x, y: y, z: z, pad1: pad1, pad2: pad2))
        }
        return count
    }

    @discardableResult
    public func transit(x: Int, y: Int, z: Int) -> Int {
        return transit(x: x, y: y, z: z, pad1: -2, pad2: -2)
    }

    @discardableResult
    internal func sync(seconds: UInt = 10) -> Int {
        //-debug-log print(Date(), "enter sync")
        if count > 0 {
            let group = DispatchGroup()
            let syncTimeout = seconds + 1
            for drone in self {
                drone.sync(group: group, seconds: seconds, timeout: drone.puppet.responseTimeout)
            }

            DroneLog.debug(String(format: "before group.wait, wait: %d seconds", syncTimeout)) //-debug-log
            let ret = group.wait(timeout: .now() + TimeInterval(syncTimeout)) == .success
            DroneLog.debug(String(format: "after group.wait, result: %@", ret ? "success" : "timeout")) //-debug-log
        }
        return count
    }
}

public protocol DroneCommandStateDelgate {
    func willExecute(manager: DroneManager, droneId: Int, command: CommandFactory.Command)
    func done(manager: DroneManager, droneId: Int, command: CommandFactory.Command, response: String)
    func statusUpdated(manager: DroneManager, droneId: Int, status: DroneStatus, response: String)
}

public class DroneManager {
    
    internal var _drones: [Drone] = [Drone]()
    internal var _droneMapping: [String: Drone] = [String:Drone]()

    private var _maxDrones = 4
    private var _responseTimeout: TimeInterval = 10
    private var _commanderUdpSocket: GCDAsyncUdpSocket? = nil
    private var _listenerUdpSocket: GCDAsyncUdpSocket? = nil
    internal var _localPort: UInt16 = 37777
    internal var _listenerPort: UInt16 = 8890
    internal var _dronePort: UInt16 = 8889
    private var _callback: ((_ manager: DroneManager) -> Void)? = nil
    internal var _limitReached = false
    internal var _semaphore: DispatchSemaphore
    private var _executeQueue: DispatchQueue
    private let _isOnExecuteQueue = DispatchSpecificKey<()>()
    
    internal var _delegate: DroneCommandStateDelgate? = nil
    internal var _delegateQueue: DispatchQueue
    private var _closed = false

    /// Constructor
    public init() {
        _semaphore  = DispatchSemaphore(value: 0)
        _executeQueue = DispatchQueue(label: "DroneManagerQueue")
        _executeQueue.setSpecific(key: _isOnExecuteQueue, value: ())

        _delegateQueue = DispatchQueue(label: "DroneManagerCommandStateDelgateQueue")
    }

    deinit {
        self.close()
    }
    
    let _ensureGroup = DispatchGroup()
    public func close() {
        //-debug-log DroneLog.info(String(format: "--------closing manager: ensureAllCommandsIssued--------"))
        guard !_closed else  {
            return
        }
        _closed = true
        var extraWait: TimeInterval = 0.0
        for drone in self._drones {
            extraWait += drone.puppet.timeoutWaitingForClose
            drone.puppet.ensureAllCommandsIssued(group: _ensureGroup)
        }
        _ = _ensureGroup.wait(timeout: .now() + extraWait)

        let waitSeconds = self._drones.count > 5 ? 5 : self._drones.count
        sleep(UInt32(waitSeconds)) // waiting for udp responses
        DroneLog.info(String(format: "--------closing manager: closing sockets--------")) //-debug-log
        if let socket = _commanderUdpSocket {
            socket.close()
            _commanderUdpSocket = nil
        }

        if let socket = _listenerUdpSocket {
            socket.close()
            _listenerUdpSocket = nil
        }
    }
    
    var _assessor: Assessor? = nil
    
    internal var assessor: Assessor? {
        get { return _assessor }
        set { _assessor = newValue }
    }

    public var maxDrones: Int {
        get {
            return runSyncWithReturnValue {
                return _maxDrones
            } as! Int
        }
    }
    
    public var responseTimeout: TimeInterval {
        get {
            return runSyncWithReturnValue {
                return _responseTimeout
                } as! TimeInterval
        }
        set {
            runBlockAsyncSafely {
                self._responseTimeout = newValue
                for drone in self.drones {
                    drone.puppet.responseTimeout = newValue
                }
            }
        }
    }
    
    public var allFound: Bool {
        get {
            return runSyncWithReturnValue {
                return _drones.count >= _maxDrones
            } as! Bool
        }
    }
    
    public var droneCount: Int {
        get {
            return runSyncWithReturnValue {
                return _drones.count
            } as! Int
        }
    }
    
    public var tellos: [Drone]  {
        get {
            return runSyncWithReturnValue {
                return _drones
                } as! [Drone]
        }
    }

    public var drones: [Drone]  {
        get {
            return runSyncWithReturnValue {
                return _drones
            } as! [Drone]
        }
    }

    func printMarkers() {
        for drone in _drones {
            print("marker: ", drone.puppet.status?.marker.id ?? "")
        }
    }

    func updateDroneStatus(drone: DronePuppet, statusString: String) -> DroneStatus {
        let results = matchByRE(pattern: DroneStatus.buildPattern(), input: statusString)
        let status = DroneStatus.build(matchedData: results)
            drone.status = status
        // DroneLog.debug(String(format: "status updated: %@, %d", statusString, status.marker.id)) //-debug-log
        return status
    }

    func createDronePuppet(id: Int, address: Data) -> DronePuppet {
        return DronePuppet(id: id, address: address, socket: _commanderUdpSocket!)
    }

    public func listeningForStatus() {
        let queue = DispatchQueue(label: "DroneManagerListenerQueue")
        let socketQueue = DispatchQueue(label: "SocketDroneManagerListenerQueue")
        _listenerUdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: queue, socketQueue: socketQueue)
        if let socket = _listenerUdpSocket {
            socket.isIPv4Enabled = true
            socket.isIPv6Enabled = false

            do {
                if !socket.didBind {
                    try socket.bind(toPort: _listenerPort)
                    try socket.receiveOnce()
                }
            } catch {
                DroneLog.error(String(format: "listening error: %@", error.localizedDescription)) //-debug-log
            }
        }
    }

    func getCommanderUdpSocket() throws -> GCDAsyncUdpSocket {
        let tryCount = 3
        if _commanderUdpSocket == nil {
            let socketQueue = DispatchQueue(label: "SocketDroneManagerCommanderQueue")
            _commanderUdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: _executeQueue, socketQueue: socketQueue)
            _commanderUdpSocket!.isIPv4Enabled = true
            _commanderUdpSocket!.isIPv6Enabled = false
            var success = false
            var e: Error? = nil
            for i in 1..<tryCount+1 {
                do {
                    try _commanderUdpSocket!.bind(toPort: _localPort)
                    try _commanderUdpSocket!.receiveOnce()
                    success = true
                    break
                } catch {
                    DroneLog.error(String(format: "bind command socket error: %@", error.localizedDescription)) //-debug-log
                    e = error
                    _commanderUdpSocket!.close()
                    sleep(UInt32(i))
                }
            }
            if !success {
                throw e!
            }
        }
        return _commanderUdpSocket!
    }

    func scan(ipAddress: String) -> Int {
        let addr4 = GCDAsyncUdpSocket.addressAndPortToData(stringAddress: ipAddress, port: 8889)
        var count = 0
        if let addr = addr4 {
            count = scan(maxDrones: 1, addresses: [addr])
        }
        DroneLog.info(String(format: "--------new scan for 1 drones( %@ ), count: %d--------", ipAddress, count)) //-debug-log
        return count
    }
    
    
    @discardableResult
    public func sync(seconds: UInt = 10) -> Int {
        return drones.sync(seconds: seconds)
    }


    @discardableResult
    public func scan(number: Int, timeout: TimeInterval = 10) -> Int {
        let addresses = GCDAsyncUdpSocket.getSubnetAddresses(interfaceDescription: "en0", port: 8889)
        let count = scan(maxDrones: number, addresses: addresses, timeout: timeout)
        if count > 0 {
            drones.getSN()
            drones.sync(seconds: 10)
            drones.mon()
            drones.sync(seconds: 10)
            drones.mdirection(direction: 0)
            drones.sync(seconds: 10)
        }
        self.assessor?.manager = self
        return count
    }
    
    func pingHosts( addresses: [Data] ) -> [Data] {
        var activeHosts = [Data]()
        let queue: OperationQueue = OperationQueue()
        queue.maxConcurrentOperationCount = 50
        for addr in addresses {
            let (hostname, _, _) = GCDAsyncUdpSocket.getHost(fromAddress: addr)
            let po = PingOperation(ip: hostname) { (error, str) in
                if error == nil {
                    DroneLog.debug(String(format: "%@ is active", hostname))
                    activeHosts.append(addr)
                }
            }
            queue.addOperation(po)
        }
        queue.waitUntilAllOperationsAreFinished()
        return activeHosts
    }

    func scan(maxDrones: Int, addresses: [Data], timeout: TimeInterval = 10) -> Int {
        var result = 0
        _executeQueue.sync {
            _maxDrones = maxDrones > addresses.count ? addresses.count : maxDrones
            _drones.removeAll()
            _droneMapping.removeAll()
            _limitReached = false
        }

        do {
            let activeHosts = pingHosts(addresses: addresses)
            DroneLog.info(String(format: "--------new scan for %d drones, timeout: %d--------", maxDrones, UInt(timeout))) //-debug-log
            DroneLog.info(String(format: "--------active hosts: %d--------", activeHosts.count)) //-debug-log
            let socket = try getCommanderUdpSocket()
            var rounds = 0
            while result < maxDrones {
                rounds += 1
                if result < maxDrones {
                    DroneLog.info(String(format: "new round: %d rounds", rounds)) //-debug-log
                }

                for addr in activeHosts {
                    socket.send("command".data(using: .utf8)!, toAddress: addr, withTimeout: timeout, tag: -1)
                    let (hostname, port, _) = GCDAsyncUdpSocket.getHost(fromAddress: addr)
                    DroneLog.debug(String(format: "scanning port %@:%d", hostname, port))
                }
                _ = _semaphore.wait(timeout: .now() + timeout + 5)
                _executeQueue.sync {
                    result = _drones.count
                    for drone in _drones {
                        drone.assessor = self._assessor
                    }
                }

                if rounds >= 10 {
                    break
                }
            }
            DroneLog.info(String(format: "scan result: %d found", result)) //-debug-log
        } catch {
            DroneLog.error(String(format: "scan error: %@", error.localizedDescription)) //-debug-log
        }

        if result > 0 {
            listeningForStatus()
        }

        return result
    }

    public func scanByBroadcast(maxDrones: Int, timeout: TimeInterval = 5, block: @escaping (_: DroneManager) -> Void) {
        assert(false)
        if _commanderUdpSocket != nil {
            _commanderUdpSocket!.close()
            _commanderUdpSocket = nil
        }
        
        _callback = block
        _maxDrones = maxDrones
        _drones.removeAll()
        _limitReached = false

        let broadAddress = GCDAsyncUdpSocket.getBroadcastAddress(interfaceDescription: "en0", port: _dronePort)
        let queue = DispatchQueue(label: "DroneManagerQueue")
        _commanderUdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: queue)
        if let socket = _commanderUdpSocket, let addr = broadAddress {
            socket.isIPv4Enabled = true
            socket.isIPv6Enabled = false

            do {
                try socket.bind(toPort: _localPort)
                try socket.enableBroadcast(true)
                socket.send("command".data(using: .utf8)!, toAddress: addr, withTimeout: timeout, tag: 1)
                try socket.beginReceiving()
                //-debug-log let (hostname, port, _) = GCDAsyncUdpSocket.getHost(fromAddress: addr)
                //-debug-log print("Started at port", _localPort, "Waiting to receive from " + hostname + ":" + String(port))
            } catch {
                DroneLog.error(String(format: "scan error: %@", error.localizedDescription)) //-debug-log
            }
        }
    }
    
    
    func runSyncWithReturnValue(block: () -> Any?) -> Any? {
        var result : Any?
        if( DispatchQueue.getSpecific(key: _isOnExecuteQueue) != nil) {
            result = block()
        } else {
            result = _executeQueue.sync(execute: block)
        }
        return result
    }
    
    func runBlockSyncSafely(block: () -> Void) {
        if( DispatchQueue.getSpecific(key: _isOnExecuteQueue) != nil) {
            block()
        } else {
            _executeQueue.sync(execute: block)
        }
    }
    
    func runBlockAsyncSafely(block: @escaping () -> Void) {
        if( DispatchQueue.getSpecific(key: _isOnExecuteQueue) != nil) {
            block()
        } else {
            _executeQueue.async(execute: block)
        }
    }
    
}
