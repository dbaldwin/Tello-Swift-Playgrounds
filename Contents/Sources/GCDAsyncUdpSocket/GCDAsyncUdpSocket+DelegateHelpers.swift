//
//  GCDAsyncUdpSocket+DelegateHelpers.swift
//  GCDAsyncUdpSocket-Swift
//
//  Created by XIAOWEI WANG on 18/05/2018.
//  Copyright © 2018 XIAOWEI WANG(mooosu@hotmail.com).
//  Inspired by CocoaAsyncSocket.
//  All rights reserved.
//



import Foundation
import Dispatch
import Darwin.TargetConditionals
import Darwin.Availability

extension GCDAsyncUdpSocket {
    
    ///////////////////////////////////////////////////////////////
    // #pragma mark Delegate Helpers
    ///////////////////////////////////////////////////////////////
    
    func notify(didConnectToAddress anAddress: Data) {
        guard let delegate = self.delegate, let queue = self.delegateQueue else {
            return
        }
        var address = Data()
        address.append(anAddress)
        queue.async {
            delegate.udpSocket(self, didConnectToAddress: address)
        }
    }
    
    func notify(didNotConnect error: Error?) {
        guard let delegate = self.delegate, let queue = self.delegateQueue else {
            return
        }
        queue.async {
            delegate.udpSocket(self, didNotConnect: error)
        }
    }
    
    func notify(didSendDataWithTag tag: Int) {
        
        guard let delegate = self.delegate, let queue = self.delegateQueue else {
            return
        }
        queue.async {
            delegate.udpSocket(self, didSendDataWithTag: tag)
        }
    }
    
    func notify(didNotSendDataWithTag tag: Int,  dueToError error: Error?) {
        guard let delegate = self.delegate, let queue = self.delegateQueue else {
            return
        }
        queue.async {
            delegate.udpSocket(self, didNotSendDataWithTag: tag, dueToError: error)
        }
    }
    
    func notify(didReceiveData data: Data, fromAddress address: Data,  withFilterContext context: AnyObject?) {
        guard let delegate = self.delegate, let queue = self.delegateQueue else {
            return
        }
        queue.async {
            delegate.udpSocket(self, didReceive: data, fromAddress: address, withFilterContext: context)
        }
    }
    
    func notify(didCloseWithError error: Error?) {
        guard let delegate = self.delegate, let queue = self.delegateQueue else {
            return
        }
        
        queue.async {
            delegate.udpSocketDidClose(self, withError: error)
        }
    }
    
}

