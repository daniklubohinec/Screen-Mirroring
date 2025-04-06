import Foundation

final class BonjourScanner: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    static let shared = BonjourScanner()
    
    private var browser: NetServiceBrowser!
    private var completion: (([String: String]) -> Void)?
    private var discoveredServices: [NetService] = []
    
    func scanForTVs(completion: @escaping ([String: String]) -> Void) {
        self.completion = completion
        discoveredServices.removeAll()
        browser = NetServiceBrowser()
        browser.delegate = self
        browser.searchForServices(ofType: "_airplay._tcp.", inDomain: "")
    }
    
    // MARK: - NetServiceBrowserDelegate
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if service.name.lowercased().contains("tv") {
            service.delegate = self
            discoveredServices.append(service)
            service.resolve(withTimeout: 5.0)
        }
        

        if !moreComing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.finishDiscovery()
            }
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        finishDiscovery()
    }
    
    // MARK: - NetServiceDelegate
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        if let hostName = sender.hostName {
            print("Found: \(sender.name) with host \(hostName)")
        } else {
            print("Could not resolve address for: \(sender.name)")
        }
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("Error resolving \(sender.name): \(errorDict)")
    }
    
    // MARK: - Завершение поиска и вызов completion
    
    private func finishDiscovery() {
        guard let completion = self.completion else { return }
        var result: [String: String] = [:]
        
        for service in discoveredServices {
            if let hostName = service.hostName {
                result[service.name] = hostName
            }
        }
        
        completion(result)
        self.completion = nil
    }
}
extension NetService {
    func getIpAddresses() -> [String] {
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        var ipAddresses = [String]()
        for address in self.addresses ?? [] {
            if address.withUnsafeBytes({
                guard let sockaddr = $0.baseAddress?.assumingMemoryBound(to: sockaddr.self) else { return false }
                return getnameinfo(sockaddr, socklen_t(address.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0
            }) {
                if let ip = String(cString: hostname).components(separatedBy: "%").first {
                    ipAddresses.append(ip)
                }
            }
        }
        return ipAddresses
    }
}
