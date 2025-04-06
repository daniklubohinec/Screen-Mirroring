import Foundation
import UIKit
import Network

public class NetworkPermissionHelper {
    
    public static let shared = NetworkPermissionHelper()
    
    private init() {}
    
    public func isConnectedToWiFi() -> Bool {
        let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        let semaphore = DispatchSemaphore(value: 0)
        var isConnected = false
        
        monitor.pathUpdateHandler = { path in
            isConnected = path.status == .satisfied
            semaphore.signal()
        }
        monitor.start(queue: .global())
        semaphore.wait()
        monitor.cancel()
        
        return isConnected
    }
    
    public func openWiFiSettings() {
        if let url = URL(string: "App-Prefs:root=WIFI") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func requestLocalNetworkPermission(completion: @escaping ((Bool) -> Void)) {
        let parameters = NWParameters.tcp
        let browser = NWBrowser(for: .bonjour(type: "_http._tcp", domain: nil), using: parameters)
        
        browser.stateUpdateHandler = { newState in
            switch newState {
            case .failed(let error):
                print("Browser failed with error: \(error)")
                completion(false)
            default:
                completion(true)
                break
            }
        }
        
        browser.browseResultsChangedHandler = { results, changes in
            for result in results {
                print("Found service: \(result)")
            }
        }
        
        browser.start(queue: .main)
    }
}
