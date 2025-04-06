import Foundation

class WebSocketService {
    private var webSocket: URLSessionWebSocketTask?
    private var clientKey: String?
    private var ipAddress: String?
    var isConnected: Bool {
        webSocket?.state == .running
    }
    
    init(ipAddress: String) {
        self.ipAddress = ipAddress
    }
    
    func connect(completion: @escaping (Bool) -> Void) {
        guard let ipAddress = ipAddress, let url = URL(string: "ws://\(ipAddress):3000") else {
            completion(false)
            return
        }
        
        webSocket = URLSession.shared.webSocketTask(with: url)
        webSocket?.resume()
        
        authenticate { success in
            completion(success)
        }
    }
    
    private func authenticate(completion: @escaping (Bool) -> Void) {
        if let clientKey = self.clientKey {
            let authMessage = """
            {
                "type": "register",
                "payload": {
                    "client-key": "\(clientKey)"
                }
            }
            """
            sendMessage(authMessage) { response in
                completion(true)
            }
        } else {
            let registerMessage = """
            {
                "type": "register",
                "payload": {
                    "forcePairing": false,
                    "manifest": {
                        "permissions": [
                            "LAUNCH",
                            "LAUNCH_WEBAPP",
                            "CONTROL_AUDIO",
                            "CONTROL_POWER",
                            "READ_INSTALLED_APPS",
                            "CONTROL_INPUT_TV",
                            "READ_TV_INFO",
                            "CONTROL_INPUT_MEDIA_RECORDING",
                            "CONTROL_INPUT_JOYSTICK",
                            "CONTROL_INPUT_SCREEN",
                            "CONTROL_INPUT_TV"
                        ]
                    }
                }
            }
            """
            sendMessage(registerMessage) { response in
                completion(true)
            }
        }
    }
    
    func sendCommand(_ command: String, completion: @escaping (Bool) -> Void) {
        let commandMessage = """
        {
            "type": "request",
            "uri": "\(command)"
        }
        """
        sendMessage(commandMessage) { response in
            completion(true)
        }
    }
    
    private func sendMessage(_ message: String, completion: @escaping (String?) -> Void) {
        guard let webSocket = webSocket else {
            completion(nil)
            return
        }
        
        webSocket.send(.string(message)) { error in
            if let error = error {
                completion(nil)
            } else {
                webSocket.receive { result in
                    switch result {
                    case .failure(let error):
                        completion(nil)
                    case .success(let message):
                        switch message {
                        case .string(let response):
                            completion(response)
                        default:
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
    }
}
