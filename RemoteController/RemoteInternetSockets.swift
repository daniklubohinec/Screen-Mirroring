//
//  RemoteInternetSockets.swift
//  RemoteController
//
//  Created by Enis Maresch on 12/02/2025.
//

import Foundation

final class WebSocketService {
    private var webSocket: URLSessionWebSocketTask?
    private let ipAddress: String
    private var clientKey: String?
    
    var isConnected: Bool {
        webSocket?.state == .running
    }
    
    init(ipAddress: String) {
        self.ipAddress = ipAddress
    }
    
    // MARK: - Connection Handling
    
    func connect(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "ws://\(ipAddress):3000") else {
            print("Invalid WebSocket URL")
            completion(false)
            return
        }
        
        webSocket = URLSession.shared.webSocketTask(with: url)
        webSocket?.resume()
        
        authenticate(completion: completion)
    }
    
    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
    }
    
    // MARK: - Authentication
    
    private func authenticate(completion: @escaping (Bool) -> Void) {
        let message: String
        if let clientKey = clientKey {
            message = """
            {
                "type": "register",
                "payload": {
                    "client-key": "\(clientKey)"
                }
            }
            """
        } else {
            message = """
            {
                "type": "register",
                "payload": {
                    "forcePairing": false,
                    "manifest": {
                        "permissions": [
                            "LAUNCH", "LAUNCH_WEBAPP", "CONTROL_AUDIO", "CONTROL_POWER",
                            "READ_INSTALLED_APPS", "CONTROL_INPUT_TV", "READ_TV_INFO",
                            "CONTROL_INPUT_MEDIA_RECORDING", "CONTROL_INPUT_JOYSTICK",
                            "CONTROL_INPUT_SCREEN", "CONTROL_INPUT_TV"
                        ]
                    }
                }
            }
            """
        }
        
        sendMessage(message) { response in
            completion(response != nil)
        }
    }
    
    // MARK: - Command Sending
    
    func sendCommand(_ command: String, completion: @escaping (Bool) -> Void) {
        let commandMessage = """
        {
            "type": "request",
            "uri": "\(command)"
        }
        """
        sendMessage(commandMessage) { response in
            completion(response != nil)
        }
    }
    
    // MARK: - Message Handling
    
    private func sendMessage(_ message: String, completion: @escaping (String?) -> Void) {
        guard let webSocket = webSocket, isConnected else {
            print("WebSocket is not connected")
            completion(nil)
            return
        }
        
        webSocket.send(.string(message)) { error in
            if let error = error {
                print("WebSocket send error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            self.receiveMessage(completion: completion)
        }
    }
    
    private func receiveMessage(completion: @escaping (String?) -> Void) {
        webSocket?.receive { result in
            switch result {
            case .failure(let error):
                print("WebSocket receive error: \(error.localizedDescription)")
                completion(nil)
            case .success(let message):
                if case .string(let response) = message {
                    completion(response)
                } else {
                    print("Received unsupported message type")
                    completion(nil)
                }
            }
        }
    }
}
