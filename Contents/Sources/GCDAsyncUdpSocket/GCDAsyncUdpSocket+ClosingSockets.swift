//
//  GCDAsyncUdpSocket+ClosingSockets.swift
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

    /**
     * Immediately closes the underlying socket.
     * Any pending send operations are discarded.
     *
     * The GCDAsyncUdpSocket instance may optionally be used again.
     *   (it will setup/configure/use another unnderlying BSD socket).
     **/
    open func close() {
        runBlockSyncSafely {
            self.closeWithError(error: nil)
        }
    }
    
    func clearSocket4Data() {
        self._socket4FD = InvalidSocket
        
        // Clear socket states
        
        self._socket4FDBytesAvailable = 0
        self.isSock4CanAcceptBytes = false
        
        
        // Clear cached info
        
        self._cachedLocalAddress4 = nil
        self._cachedLocalHost4 = nil
        self._cachedLocalPort4 = 0;
    }
    
    func clearSocket6Data() {
        self._socket6FD = InvalidSocket
        
        // Clear socket states
        
        self._socket6FDBytesAvailable = 0
        self.isSock6CanAcceptBytes = false
        
        
        // Clear cached info
        
        self._cachedLocalAddress6 = nil
        self._cachedLocalHost6 = nil
        self._cachedLocalPort6 = 0
    }
    
    func closeSocket4() {
        if (socket4FD != InvalidSocket) {
            print("dispatch_source_cancel(send4Source)");
            self._send4Source?.cancel()
            
            print("dispatch_source_cancel(receive4Source)");
            self._receive4Source?.cancel()
            
            
            // For some crazy reason (in my opinion), cancelling a dispatch source doesn't
            // invoke the cancel handler if the dispatch source is paused.
            // So we have to unpause the source if needed.
            // This allows the cancel handler to be run, which in turn releases the source and closes the socket.
            
            self.resumeSend4Source()
            self.resumeReceive4Source()
            
            // The sockets will be closed by the cancel handlers of the corresponding source
            
            self._send4Source = nil;
            self._receive4Source = nil;
            
            self.clearSocket4Data()
        }
    }
    
    func closeSocket6() {
        if (socket6FD != InvalidSocket) {
            print("dispatch_source_cancel(send6Source)")
            self._send6Source?.cancel()
            
            print("dispatch_source_cancel(receive6Source)")
            self._receive6Source?.cancel()
            
            
            // For some crazy reason (in my opinion), cancelling a dispatch source doesn't
            // invoke the cancel handler if the dispatch source is paused.
            // So we have to unpause the source if needed.
            // This allows the cancel handler to be run, which in turn releases the source and closes the socket.
            
            self.resumeSend6Source()
            self.resumeReceive6Source()
            
            // The sockets will be closed by the cancel handlers of the corresponding source
            
            self._send6Source = nil
            self._receive6Source = nil
            
            self.clearSocket6Data()
        }
    }
    
    func closeSockets() {
        self.closeSocket4()
        self.closeSocket6()
        self.didCreateSockets = false
    }
    
    /**
     * Closes the underlying socket after all pending send operations have been sent.
     *
     * The GCDAsyncUdpSocket instance may optionally be used again.
     *   (it will setup/configure/use another unnderlying BSD socket).
     **/
    open func closeAfterSending() {
        
    }
    /**
     * Releases all resources associated with the currentSend.
     **/
    func endCurrentSend()
    {
        if let timer = self._sendTimer {
            timer.cancel()
            self._sendTimer = nil
        }
        self._currentSend = nil
    }
    
    func closeWithError(error: Error?) {
        print("closeWithError: ", error?.localizedDescription ?? "")
        assert(self.isSocketQueue, "Must be dispatched on socketQueue");
        
        if (self._currentSend != nil) {
            self.endCurrentSend()
        }

        self._sendQueue.removeAll()
        
        self.closeSockets()
        
        // Clear all flags (config remains as is)
        self._flags = 0
        
        if (self.didCreateSockets) {
            self.notify(didCloseWithError: error)
        }
    }

}

