//
//  TroubleshootingViewController.swift
//  TroubleshootingViewController
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

import UIKit
import PlaygroundSupport

@objc(TroubleshootingViewController)
public class TroubleshootingViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {

    @IBOutlet weak var tvLogView: UITextView!
    @IBOutlet weak var lbVersion: UILabel!

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initLogger()
        tvLogView.text = readLog()
    }

    func setupVersionLabel() {
        lbVersion.text = "Build: \(getBuild())  Date: \(getDateVersion()) Git: \(getGitHash())"
    }
    
    func readLog() -> String {
        let logFileURL = (logger.destinations.first as! FileDestination).logFileURL!
        if FileManager.default.fileExists(atPath: logFileURL.relativePath) {
            do {
                return try String(contentsOf: logFileURL, encoding: .utf8)
            } catch {
                return "Read log file error: \(error)"
            }
        }
        return "Log file not exists"
    }
    
    func showMessage(message: String) {
        let toast = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
        
        self.present(toast, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            toast.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onCopy(_ sender: Any) {
        let pb = UIPasteboard.general
        pb.string = tvLogView.text
        showMessage(message: "Copied")
    }
    
    @IBAction func onTruncate(_ sender: Any) {
        let logFileURL = (logger.destinations.first as! FileDestination).logFileURL!
        if FileManager.default.fileExists(atPath: logFileURL.relativePath) {
            let text = ""
            do {
                try text.write(to: logFileURL, atomically: false, encoding: .utf8)
                tvLogView.text = text
                showMessage(message: "Truncated")
            } catch {
                showMessage(message: "Truncating failed: \(error)")
            }
        } else {
            showMessage(message: "Log file not exists")
        }
    }
}
