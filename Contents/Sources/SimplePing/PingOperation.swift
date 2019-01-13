//
//  SimplePing.swift
//  SimplePing
//
//  Created by XIAOWEI WANG on 2018/8/13.
//  Inspired by Michael Mavris.
//  Copyright © 2018 XIAOWEI WANG. All rights reserved.
//

import Foundation

class PingOperation: Operation, SimplePingDelegate {
    func simplePing(pinger: SimplePing, didStartWithAddress address: Data) {
        if self.isCancelled {
            self.finish()
            return
        }
        pinger.sendPingWithData()
    }

    func simplePing(pinger: SimplePing, didFailWithError error: NSError?) {
        _pingTimer?.invalidate()
        _errorMessage = error
        self.finishedPing()
    }

    func simplePing(pinger: SimplePing, didFailToSendPacket packet: Data, error: NSError?) {
        _pingTimer?.invalidate()
        _errorMessage = error
        self.finishedPing()
    }

    func simplePing(pinger: SimplePing, didReceivePingResponsePacket packet: Data) {
        _pingTimer?.invalidate()
        self.finishedPing()
    }

    func simplePing(pinger: SimplePing, didSendPacket packet: Data) {
        let pingTimeout: TimeInterval = 1
        _pingTimer = Timer.scheduledTimer(timeInterval: pingTimeout, target: self, selector: #selector(PingOperation.pingTimeOut(timer:)), userInfo: nil, repeats: false)
    }

    @objc func pingTimeOut(timer: Timer) {
        // Move to next host
        _errorMessage = NSError(domain: "Ping timeout", code: 11, userInfo: nil)
        self.finishedPing()
    }

    func simplePing(pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) {
        //print("didReceiveUnexpectedPacket")
    }

    var _ipStr: String? = nil
    var _simplePing: SimplePing!

    var _stopRunLoop:   Bool = false
    var _keepAliveTimer: Timer? = nil
    var _pingTimer:      Timer? = nil
    var _errorMessage:   NSError? = nil
    var _result:         ((NSError?, String) -> Void)? = nil
    
    private var _executing : Bool = false
    private var _finished : Bool = false

    
    init(ip: String, CompletionHandler result: ((NSError?, String) -> Void)? ) {
        super.init()
        self._ipStr = ip
        self._simplePing = SimplePing(hostName: ip)
        _simplePing._delegate = self
        _result = result
        _executing = false
        _finished = false
        
        self.name = ip
    }
    
    override var isExecuting : Bool {
        get { return _executing }
    }
    
    private func setIsExecuting( executing: Bool ) {
        guard _executing != executing else { return }
        willChangeValue(forKey: "isExecuting")
        _executing = executing
        didChangeValue(forKey: "isExecuting")
    }

    override var isFinished : Bool {
        get { return _finished }
    }
    
    private func setIsFinished( finished: Bool ) {
        guard _finished != finished else { return }
        willChangeValue(forKey: "isFinished")
        _finished = finished
        didChangeValue(forKey: "isFinished")
    }

    override func start() {
        if self.isCancelled {
            setIsFinished(finished: true)
            return
        }
        setIsExecuting(executing: true)

        let runLoop = RunLoop.current
        
        _keepAliveTimer = Timer(timeInterval: 1000000.0, target: self, selector: #selector(PingOperation.timeout(timer:)), userInfo: nil, repeats: false)
        runLoop.add(_keepAliveTimer!, forMode: .defaultRunLoopMode)
        
        self.ping()
        
        let updateInterval = 0.1
        var loopUntil = Date(timeIntervalSinceNow: updateInterval)
        while !_stopRunLoop && runLoop.run(mode: .defaultRunLoopMode, before: loopUntil) {
            loopUntil = Date(timeIntervalSinceNow: updateInterval)
        }
    }

    func ping() {
        self._simplePing.start()
    }

    func finishedPing() {
        if let handler = self._result {
            handler(_errorMessage, self.name!)
        }
        self.finish()
    }

    @objc func timeout( timer: Timer) {
        //This method should never get called. (just in case)
        _errorMessage = NSError(domain: "Ping Timeout", code: 10, userInfo: nil)
        self.finishedPing()
    }
    
    func finish() {
        _keepAliveTimer?.invalidate()
        _keepAliveTimer = nil
        
        _stopRunLoop = true
        
        setIsExecuting(executing: false)
        setIsFinished(finished: true)
        
    }
}
