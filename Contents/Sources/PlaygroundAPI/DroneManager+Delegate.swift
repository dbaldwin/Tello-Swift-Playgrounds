//
//  DroneManager+Delegate.swift
//  DroneManager+Delegate
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

extension DroneManager: GCDAsyncUdpSocketDelegate {
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        let (host4, port4, family4) = GCDAsyncUdpSocket.getHost(fromAddress: address)
        DroneLog.info( String(format:  "Connected to %@, %d, %d", host4, port4, family4)) //-debug-log
    }

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        if let e = error {
            DroneLog.error( e.localizedDescription) //-debug-log
        } else {
            DroneLog.error("Unknow error") //-debug-log
        }
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        if tag != -1 {
            var command = ""
            switch tag {
            case "scanning".hashValue:
                command = "scanning" // virtual command, never happen
            case "command".hashValue:
                command = "command"
            case "mon".hashValue:
                command = "mon"
            case "takeoff".hashValue:
                command = "takeoff"
            case "land".hashValue:
                command = "land"
            default:
                if tag < 10 {
                    if tag > 0 && tag <= self._drones.count {
                        let drone = self._drones[tag - 1]
                        let lastCmd = drone.puppet.lastCommand
                        let lastCmdString = drone.puppet.lastCommandString
                        _delegateQueue.async {
                            if let delegate = self._delegate {
                                delegate.willExecute(manager: self, droneId: tag, command: lastCmd)
                            }
                        }
                        DroneLog.debug(String(format: "send data tag: %d(drone id), %@", tag, lastCmdString)) //-debug-log
                    } else {
                        DroneLog.debug(String(format: "send data tag: %d, (count: %d) no drones matched", tag, self._drones.count)) //-debug-log
                    }
                } else {
                    DroneLog.debug(String(format: "command: tag >= 10, tag: %d", tag)) //-debug-log
                }
            }
            if !command.isEmpty {
                DroneLog.debug(String(format: "command: %@, tag: %d", command, tag)) //-debug-log
            }
        }
    }

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        if let e = error {
            DroneLog.error(String(format: "tag: %d, error: %@", tag, e.localizedDescription)) //-debug-log
        } else {
            DroneLog.error(String(format: "tag: %d", tag)) //-debug-log
        }
    }

    func addDrone(address: Data) {
        runBlockAsyncSafely {
            let (host, port, _) = GCDAsyncUdpSocket.getHost(fromAddress: address)
            let stringAddress = String(format: "%@:%d", host, port)
            let puppet = self.createDronePuppet(id: self._drones.count + 1, address: address)
            let drone = Drone(dronePuppet: puppet)
            self._drones.append(drone)
            self._droneMapping[stringAddress] = drone
        }
    }

    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let (host, port, _) = GCDAsyncUdpSocket.getHost(fromAddress: address)
        let stringAddress = String(format: "%@:%d", host, port)
        if sock.localPort == _localPort { // command response
            if let response = String(data: data, encoding: .utf8) {

                if let drone = _droneMapping[stringAddress] {

                    // notify delegate
                    let lastCmd = drone.puppet.lastCommand
                    _delegateQueue.async {
                        if let delegate = self._delegate {
                            delegate.done(manager: self, droneId: drone.puppet.id,
                                          command: lastCmd, response: response)
                        }
                    }

                    drone.notifyResponse(response: response)

                } else {
                    if response.lowercased() == "ok" {
                        if _limitReached {
                            DroneLog.warning(String(format: "drones exceed the limit, ignore: %@, %d, %@",host, port, response)) //-debug-log
                            return
                        }
                        self.addDrone(address: address)
                        DroneLog.info(String(format: "drone found: %@, %d, %@",host, port, response)) //-debug-log
                        _limitReached = allFound
                        if _limitReached {
                            DroneLog.info(String(format: "Found %d drones", maxDrones)) //-debug-log
                            _semaphore.signal()
                            sock.endCurrentSend()
                            sock._sendQueue.removeAll()
                        }
                    }
                }
            } else {
                DroneLog.error(String(format: "drone found: : %@, %d, %@",host, port, "invalid message")) //-debug-log
            }
        } else if sock.localPort == _listenerPort {
            if let response = String(data: data, encoding: .utf8) {
                if response.lowercased().starts(with: "mid:"){ // status info
                    if let drone = _droneMapping[stringAddress] {
                            let status = self.updateDroneStatus(drone: drone.puppet, statusString: response)
                            _delegateQueue.async {
                                if let delegate = self._delegate {
                                    delegate.statusUpdated(manager: self, droneId: drone.puppet.id,
                                                           status: status, response: response)
                                }
                            }
                    } else {
                        // message is not from drone
                        //-debug-log print("drone not found: ", stringAddress)
                    }
                }
            }
        }
        do {
            try sock.receiveOnce()
        } catch {
            
        }
    }

    public func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        //
    }
}
