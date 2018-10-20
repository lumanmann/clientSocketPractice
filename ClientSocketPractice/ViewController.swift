//
//  ViewController.swift
//  ClientSocketPractice
//
//  Created by WY NG on 20/10/2018.
//  Copyright © 2018 lumanman. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController {
    
    var clientSocket : GCDAsyncSocket?
    
    let hostIP = "192.168.1.25"
    let port : UInt16 = 5555
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.isEnabled = false
        
        // 1. 建立
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        // 2. 建立連線
        do {
            try clientSocket?.connect(toHost: hostIP, onPort: port)
        } catch {
            print("連線失敗")
        }
        
        
    }


    @IBAction func sendClicked(_ sender: UIButton) {
        
        guard let inputText = inputTextField.text else {
            return
        }
        
        var currentext = messageTextView.text
        
        currentext = currentext ?? "" + "\nMe : \(inputText)"
        
        messageTextView.text = currentext
            
        let data = inputTextField.text?.data(using: String.Encoding.utf8)
        
        // -1 不timeout
        clientSocket?.write(data ?? Data(), withTimeout: -1, tag: 0)
        
    }
}

extension ViewController: GCDAsyncSocketDelegate {
   
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print(host)
        print(port)
        print("connection success")
        
        sendButton.isEnabled = true
        
        
        // 3. 開始讀取資料
        self.clientSocket?.readData(withTimeout: -1, tag: 0)
    
    }
    
    // disconnect
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("disconnect")
        sendButton.isEnabled = false
    
    }
    
    // 4. 接收到資料
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let message = String(data: data, encoding: String.Encoding.utf8)
        
        let currentText = messageTextView.text!
        
        let text = "\nFrom Server: \(message!)"
        
        messageTextView.text = currentText + text
        
        // 繼續讀資料 （因爲它只會讀一次）
        self.clientSocket?.readData(withTimeout: -1, tag: 0)
    }
}
