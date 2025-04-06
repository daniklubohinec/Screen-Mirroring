//
//  RemoteButtonControllerSetup.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit

class RemoteButtonControllerSetup {
    private var ipAddress: String?
    private var bonjourScanner: RemotePreviewingView = .shared
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
        guard let webSocketService = webSocketService else {
            print("WebSocketService not initialized. Please perform TV discovery.")
            return
        }
        
        webSocketService.connect { success in
            if success {
                print("Successfully connected to the TV.")
            } else {
                print("Failed to connect to the TV.")
                self.showAlert(message: "Connecting error occured")
            }
        }
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        //            self.showAlert(message: "Connecting error occured")
        //        }
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
        EfficinacyCaller.shared.callHaptic()
        //        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
        
        webSocketService?.sendCommand("ssap://system/turnOff") { [self] success in
            if success {
                print("TV turned off.")
                //                        showAlert(message: "TV turned off.")
            } else {
                print("Failed to execute power off command.")
                showAlert(message: "Failed to execute power off command.")
            }
        }
    }
    
    func openSettings() {
        EfficinacyCaller.shared.callHaptic()
        //        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
        
        webSocketService?.sendCommand("ssap://system/settings") { [self] success in
            if success {
                print("Settings opened")
                //                showAlert(message: "Settings opened")
            } else {
                print("Failed to open settings")
                showAlert(message: "Failed to open settings")
            }
        }
    }
    
    func changeSource() {
        EfficinacyCaller.shared.callHaptic()
        //        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
        
        webSocketService?.sendCommand("ssap://tv/switchInput") { [self] success in
            if success {
                print("Source changed")
                //                showAlert(message: "Source changed")
            } else {
                print("Failed to change source")
                showAlert(message: "Failed to change source")
            }
        }
    }
    
    func exit() {
        EfficinacyCaller.shared.callHaptic()
        //        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
        
        webSocketService?.sendCommand("ssap://system/exitApp") { [self] success in
            if success {
                print("Exit performed")
                //                showAlert(message: "Exit performed")
            } else {
                print("Failed to perform exit")
                showAlert(message: "Failed to perform exit")
            }
        }
    }
    
    func navigate(direction: String) {
        EfficinacyCaller.shared.callHaptic()
        //        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
        
        let command = "ssap://input/navigate?direction=\(direction)"
        webSocketService?.sendCommand(command) { [self] success in
            if success {
                print("Navigation performed: \(direction)")
                //                showAlert(message: "Navigation performed: \(direction)" )
            } else {
                print("Failed to perform navigation: \(direction)")
                showAlert(message: "Failed to perform navigation: \(direction)")
            }
        }
    }
    
    func ok() {
        EfficinacyCaller.shared.callHaptic()
        //        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
        
        webSocketService?.sendCommand("ssap://input/ok") { [self] success in
            if success {
                print("OK button pressed")
                //                showAlert(message: "OK button pressed")
            } else {
                print("Failed to press OK")
                showAlert(message: "Failed to press OK")
            }
        }
    }
    
    func returnAction() {
        EfficinacyCaller.shared.callHaptic()
        //        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
        
        webSocketService?.sendCommand("ssap://input/return") { [self] success in
            if success {
                print("Return performed")
                //                showAlert(message: "Return performed")
            } else {
                print("Failed to perform return")
                showAlert(message: "Failed to perform return")
            }
        }
    }
    
    func home() {
        EfficinacyCaller.shared.callHaptic()
        //        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
        
        webSocketService?.sendCommand("ssap://system/launcher/open") { [self] success in
            if success {
                print("Navigated to home screen")
                //                showAlert(message: "Navigated to home screen")
            } else {
                print("Failed to navigate to home screen")
                showAlert(message: "Failed to navigate to home screen")
            }
        }
    }
    
    func mediaControl(action: String) {
        EfficinacyCaller.shared.callHaptic()
        //        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
        
        let command = "ssap://media.controls/\(action)"
        webSocketService?.sendCommand(command) { [self] success in
            if success {
                print("Media action performed: \(action)")
                //                showAlert(message: "Media action performed: \(action)")
            } else {
                print("Failed to perform media action: \(action)")
                showAlert(message: "Failed to perform media action: \(action)")
            }
        }
    }
    
    func channelControl(action: String) {
        EfficinacyCaller.shared.callHaptic()
        //        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
        
        switch action {
        case "up":
            webSocketService?.sendCommand("ssap://tv/channelUp") { [self] success in
                if success {
                    print("Channel switched to next")
                    //                    showAlert(message: "Channel switched to next")
                } else {
                    print("Failed to switch channel to next")
                    showAlert(message: "Failed to switch channel to next")
                }
            }
        case "down":
            webSocketService?.sendCommand("ssap://tv/channelDown") { [self] success in
                if success {
                    print("Channel switched to previous")
                    //                    showAlert(message: "Channel switched to previous")
                } else {
                    print("Failed to switch channel to previous")
                    showAlert(message: "Failed to switch channel to previous")
                }
            }
        case "list":
            webSocketService?.sendCommand("ssap://tv/getChannelList") { [self] success in
                if success {
                    print("Channel list opened")
                    //                    showAlert(message: "Unsupported action for channels")
                } else {
                    print("Failed to open channel list")
                    showAlert(message: "Unsupported action for channels")
                }
            }
        default:
            print("Unsupported action for channels")
            showAlert(message: "Unsupported action for channels")
        }
    }
    
    func changeVolume(action: String) {
        EfficinacyCaller.shared.callHaptic()
        //        showAlert(message: connected ? "Your TV does not support this feature" : "Connect to a TV first")
        
        let command: String
        switch action {
        case "up":
            command = "ssap://audio/volumeUp"
        case "down":
            command = "ssap://audio/volumeDown"
        case "mute":
            command = "ssap://audio/setMute"
        default:
            print("Unsupported action for volume")
            showAlert(message: "Unsupported action for volume")
            return
        }
        
        webSocketService?.sendCommand(command) { [self] success in
            if success {
                print("Volume command executed: \(action)")
                //                showAlert(message: "Volume command executed: \(action)")
            } else {
                print("Failed to execute volume command.")
                showAlert(message: "Failed to execute volume command.")
            }
        }
    }
}
