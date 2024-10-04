import Foundation
import UIKit

class TVController {
    private var ipAddress: String?
    private var bonjourScanner: BonjourScanner = .shared
    private var isOn: Bool = false
    private var currentVolume: Int = 50
    private var currentChannel: Int = 1
    private var selectedTV: (name: String, ipAddress: String)?
    private var webSocketService: WebSocketService?
    private var connected: Bool {
        webSocketService?.isConnected ?? false
    }
    
    init() {    }
    
    func discoverTV(completion: @escaping (Bool) -> Void) {
        bonjourScanner.scanForTVs { [weak self] result in
            if let firstTV = result.first {
                let tvName = firstTV.key
                let tvIpAddress = firstTV.value
                self?.selectedTV = (tvName, tvIpAddress)
                self?.webSocketService = WebSocketService(ipAddress: tvIpAddress)
                print("TV discovered: \(tvName) with IP address: \(tvIpAddress)")
                completion(true)
            } else {
                print("TV not discovered")
                completion(false)
            }
        }
    }
    
    func selectTV(name: String, ipAddress: String) {
        self.selectedTV = (name, ipAddress)
        self.ipAddress = ipAddress
        self.webSocketService = WebSocketService(ipAddress: ipAddress)
        print("Selected TV: \(name) with IP address: \(ipAddress)")
    }
    
    func connect() {
//        guard let webSocketService = webSocketService else {
//            print("WebSocketService not initialized. Please perform TV discovery.")
//            return
//        }
//        
//        webSocketService.connect { success in
//            if success {
//                print("Successfully connected to the TV.")
//            } else {
//                print("Failed to connect to the TV.")
//            }
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showAlert(message: "Connecting error occured")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            window.topViewController()?.present(alert, animated: true)
        }
    }
    
    func disconnect() {
        webSocketService?.disconnect()
        print("Disconnected from the TV.")
    }
    
    func togglePower() {
        HapticGenerator.shared.generateImpact()
        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
//        webSocketService?.sendCommand("ssap://system/turnOff") { success in
//            if success {
//                print("TV turned off.")
//            } else {
//                print("Failed to execute power off command.")
//            }
//        }
    }
    
    func openSettings() {
        HapticGenerator.shared.generateImpact()
        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")

//        webSocketService?.sendCommand("ssap://system/settings") { success in
//            if success {
//                print("Settings opened")
//            } else {
//                print("Failed to open settings")
//            }
//        }
    }
    
    func changeSource() {
        HapticGenerator.shared.generateImpact()
        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")

//        webSocketService?.sendCommand("ssap://tv/switchInput") { success in
//            if success {
//                print("Source changed")
//            } else {
//                print("Failed to change source")
//            }
//        }
    }
    
    func exit() {
        HapticGenerator.shared.generateImpact()
        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")

//        webSocketService?.sendCommand("ssap://system/exitApp") { success in
//            if success {
//                print("Exit performed")
//            } else {
//                print("Failed to perform exit")
//            }
//        }
    }
    
    func navigate(direction: String) {
        HapticGenerator.shared.generateImpact()
        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")

//        let command = "ssap://input/navigate?direction=\(direction)"
//        webSocketService?.sendCommand(command) { success in
//            if success {
//                print("Navigation performed: \(direction)")
//            } else {
//                print("Failed to perform navigation: \(direction)")
//            }
//        }
    }
    
    func ok() {
        HapticGenerator.shared.generateImpact()
        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")

//        webSocketService?.sendCommand("ssap://input/ok") { success in
//            if success {
//                print("OK button pressed")
//            } else {
//                print("Failed to press OK")
//            }
//        }
    }
    
    func returnAction() {
        HapticGenerator.shared.generateImpact()
        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
//
//        webSocketService?.sendCommand("ssap://input/return") { success in
//            if success {
//                print("Return performed")
//            } else {
//                print("Failed to perform return")
//            }
//        }
    }
    
    func home() {
        HapticGenerator.shared.generateImpact()
        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
//
//        webSocketService?.sendCommand("ssap://system/launcher/open") { success in
//            if success {
//                print("Navigated to home screen")
//            } else {
//                print("Failed to navigate to home screen")
//            }
//        }
    }
    
    func mediaControl(action: String) {
        HapticGenerator.shared.generateImpact()
        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
//
//        let command = "ssap://media.controls/\(action)"
//        webSocketService?.sendCommand(command) { success in
//            if success {
//                print("Media action performed: \(action)")
//            } else {
//                print("Failed to perform media action: \(action)")
//            }
//        }
    }
    
    func channelControl(action: String) {
        HapticGenerator.shared.generateImpact()
        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
//
//        switch action {
//        case "up":
//            webSocketService?.sendCommand("ssap://tv/channelUp") { [weak self] success in
//                if success {
//                    print("Channel switched to next")
//                } else {
//                    print("Failed to switch channel to next")
//                }
//            }
//        case "down":
//            webSocketService?.sendCommand("ssap://tv/channelDown") { [weak self] success in
//                if success {
//                    print("Channel switched to previous")
//                } else {
//                    print("Failed to switch channel to previous")
//                }
//            }
//        case "list":
//            webSocketService?.sendCommand("ssap://tv/getChannelList") { success in
//                if success {
//                    print("Channel list opened")
//                } else {
//                    print("Failed to open channel list")
//                }
//            }
//        default:
//            print("Unsupported action for channels")
//        }
    }

    func changeVolume(action: String) {
        HapticGenerator.shared.generateImpact()
        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
//
//        let command: String
//        switch action {
//        case "up":
//            command = "ssap://audio/volumeUp"
//        case "down":
//            command = "ssap://audio/volumeDown"
//        case "mute":
//            command = "ssap://audio/setMute"
//        default:
//            print("Unsupported action for volume")
//            return
//        }
//        
//        webSocketService?.sendCommand(command) { success in
//            if success {
//                print("Volume command executed: \(action)")
//            } else {
//                print("Failed to execute volume command.")
//            }
//        }
    }
}
