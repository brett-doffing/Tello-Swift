// ViewController.swift

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController, GCDAsyncUdpSocketDelegate {
    
    var socket = GCDAsyncUdpSocket()
    let sendHost = "192.168.10.1"
    let sendPort: UInt16 = 8889
    let statePort: UInt16 = 8890
    
    @IBAction func touchedBattery(_ sender: Any) {
        sendCommand(command: "battery?")
    }
    
    @IBAction func touchedTakeoff(_ sender: Any) {
        sendCommand(command: "takeoff")
    }
    
    @IBAction func touchedLand(_ sender: Any) {
        sendCommand(command: "land")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        setupCommand()
        setupListener()
    }
    
//    func processStreamData(streamData: Dictionary<String, Double>) {
//        //print(streamData)
//    }
    
    func setupCommand() {
        // Set the delegate and dispatch queue
        socket.setDelegate(self)
        socket.setDelegateQueue(DispatchQueue.main)
        
        // Send the "command" command to the socket.
        do {
            try socket.bind(toPort: sendPort)
            try socket.enableBroadcast(true)
            try socket.beginReceiving()
            socket.send("command".data(using: String.Encoding.utf8)!,
                        toHost: sendHost,
                        port: sendPort,
                        withTimeout: 0,
                        tag: 0)
        } catch {
            print("Command command sent.")
        }
    }
    
    func setupListener() {
        let receiveSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try receiveSocket.bind(toPort: statePort)
        } catch {
            print("Bind Problem")
        }
        
        do {
            try receiveSocket.beginReceiving()
        } catch {
            print("Receiving Problem")
        }
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let dataString = String(data: data, encoding: String.Encoding.utf8)
        if (sock.localPort() == sendPort) {
            print(dataString)
        }
        
        if (sock.localPort() == statePort) {
            print(dataString)
        }
        
        // Separates streamed data
//        if (sock.localPort() == statePort) {
//            var telloStateDictionary = [String:Double]()
//            let stateArray = dataString?.components(separatedBy: ";")
//
//            for itemState in stateArray! {
//                let keyValueArray = itemState.components(separatedBy: ":")
//                if (keyValueArray.count == 2) {
//                    telloStateDictionary[keyValueArray[0]] = Double(keyValueArray[1])
//                }
//            }
//            processStreamData(streamData: telloStateDictionary)
//        }
    }
    
    func sendCommand(command: String) {
        let message = command.data(using: String.Encoding.utf8)
        socket.send(message!, toHost: sendHost, port: sendPort, withTimeout: 2, tag: 0)
    }
}

