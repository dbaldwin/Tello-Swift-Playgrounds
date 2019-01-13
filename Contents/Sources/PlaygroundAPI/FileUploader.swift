//
//  FileUploader.swift
//  FileUploader
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
public class FileUploader: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    var _responseData = Data()
    let _delegateQueue = OperationQueue()
    let _sempaphore = DispatchSemaphore(value: 0)
    var _statusCode = 0
    var _error: Error? = nil
    var _timeout = false
    public var StatusCode : Int {
        return _statusCode
    }
    public var Error: Error?  {
        return _error
    }
    
    public var succeed: Bool {
        return _statusCode == 200
    }
    
    public var timeout: Bool {
        return _timeout
    }

    public func uploadFile(path: String, remoteURL: String, timeout: TimeInterval = 5) -> DispatchTimeoutResult {
        return uploadFile(path: URL(fileURLWithPath: path), remoteURL: remoteURL, timeout: timeout)
    }
    
    public func uploadFile(path: URL, remoteURL: String, timeout: TimeInterval = 5) -> DispatchTimeoutResult {
        let data = try! Data(contentsOf: path)
        var request = URLRequest(url: URL(string:remoteURL)!)
        request.httpMethod = "POST"
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        _delegateQueue.addOperation {
            self.uploadFiles(request: request, data: data)
        }
        let result = _sempaphore.wait(timeout: .now() + timeout)
        _timeout = result == .success
        return result
    }
    
    func uploadFiles(request: URLRequest, data: Data) {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: _delegateQueue)
        let task = session.uploadTask(with: request as URLRequest, from: data as Data)
        task.resume()
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let response = task.response as? HTTPURLResponse {
            _statusCode = response.statusCode
        }
        _error = error
        _sempaphore.signal()
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        print("session \(session) uploaded \(uploadProgress * 100)%.")
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("session \(session), received response \(response)")
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        _responseData.append(data as Data)
    }
}
