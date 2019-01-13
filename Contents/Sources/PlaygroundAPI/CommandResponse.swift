//
//  CommandResponse.swift
//  CommandResponse
//
/*
 
 * @version 1.0
 
 * @date Sep 2018
 
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
 * Created by XIAOWEI WANG on 03/09/2018.
 * support@ryzerobotics.com
 *
 
 */
import Foundation
import PlaygroundSupport

public class DroneCommandResponse : DroneCommandStateDelgate{
    public func statusUpdated(manager: DroneManager, droneId: Int, status: DroneStatus, response: String) {
        if let handler = PlaygroundPage.current.liveView as? PlaygroundLiveViewMessageHandler {
            // DroneLog.debug(String(format: "%d:%@",  droneId, response))
            let drone = manager.drones[droneId - 1]
            if drone.status == nil {
                let command = CommandFactory.Command.droneStatus(status: status)
                handler.send(command.toPlaygroundValue(droneId: droneId))
            }
        }
    }
    
    public func willExecute(manager: DroneManager, droneId: Int, command: CommandFactory.Command) {
        if case .getSN( _) = command {
            DroneLog.debug(String(format: "getSN ignore"))
            return
        }
        if let handler = PlaygroundPage.current.liveView as? PlaygroundLiveViewMessageHandler {
            handler.send(command.toPlaygroundValue(droneId: droneId))
            let drone = manager.drones[droneId - 1]
            DroneLog.debug(String(format: "delegate willExecute: %@:%@", command.toString(), drone.puppet.lastCommandString))
            if let status = drone.status {
                let command = CommandFactory.Command.droneStatus(status: status)
                handler.send(command.toPlaygroundValue(droneId: droneId))
            }
        } else {
            DroneLog.debug(String(format: "handler is null: %@", command.toString()))
        }
    }
    
    public func done(manager: DroneManager, droneId: Int, command: CommandFactory.Command, response: String) {
        if let handler = (PlaygroundPage.current.liveView as? PlaygroundLiveViewMessageHandler) {
            if case .getSN( _) = command {
                let cmd: CommandFactory.Command = .getSN(sn: response)
                handler.send(cmd.toPlaygroundValue(droneId: droneId))
            }
        }
        DroneLog.debug(String(format: "delegate done: %@", command.toString()))
    }
}
