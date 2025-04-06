//
//  RemotePreviewingView.swift
//  RemoteController
//
//  Created by Enis Maresch on 12/02/2025.
//

import Foundation

final class RemotePreviewingView: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    static let shared = RemotePreviewingView()
    
    private lazy var browser: NetServiceBrowser = {
        let browser = NetServiceBrowser()
        browser.delegate = self
        return browser
    }()
    
    private var completion: (([String: String]) -> Void)?
    private var discoveredServices = [NetService]()
    
    func scanForTVs(completion: @escaping ([String: String]) -> Void) {
        self.completion = completion
        discoveredServices.removeAll()
        browser.searchForServices(ofType: "_airplay._tcp.", inDomain: "")
    }
    
    // MARK: - NetServiceBrowserDelegate
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        guard service.name.lowercased().contains("tv") else { return }
        
        service.delegate = self
        discoveredServices.append(service)
        service.resolve(withTimeout: 5.0)

        if !moreComing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: finishDiscovery)
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
        finishDiscovery()
    }
    
    // MARK: - NetServiceDelegate
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let hostName = sender.hostName else {
            print("Could not resolve address for: \(sender.name)")
            return
        }
        print("Found: \(sender.name) with host \(hostName)")
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
        print("Error resolving \(sender.name): \(errorDict)")
    }
    
    // MARK: - Finish Discovery
    
    private func finishDiscovery() {
        DispatchQueue.main.async {
            let result = self.discoveredServices.reduce(into: [String: String]()) { result, service in
                if let hostName = service.hostName {
                    result[service.name] = hostName
                }
            }
            self.completion?(result)
            self.completion = nil
        }
    }
}

// MARK: - NetService Extension

extension NetService {
    func getIpAddresses() -> [String] {
        var ipAddresses = [String]()
        addresses?.forEach { address in
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            
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
