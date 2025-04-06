//
//  RemoteConnectorInitView.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import SwiftUI

struct RemoteConnectorInitView: View {
    @State private var discoveredTVs: [String: String] = [:]
    @State private var isSearching = false
    @Binding var isPresented: Bool
    let onTVSelected: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            List {
                if isSearching {
                    ProgressView("Searching devices...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical)
                } else if discoveredTVs.isEmpty {
                    Text("Devices not found")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(Array(discoveredTVs.keys), id: \.self) { tvName in
                        Button(action: {
                            if let ipAddress = discoveredTVs[tvName] {
                                onTVSelected(tvName, ipAddress)
                                isPresented = false
                            }
                        }) {
                            HStack {
                                Image(systemName: "weigfwefdfasdasdas")
                                    .foregroundColor(.blue)
                                Text(tvName)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose TV")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
        .onAppear {
            searchForTVs()
        }
    }
    
    private func searchForTVs() {
        isSearching = true
        let scanner = RemotePreviewingView.shared
        scanner.scanForTVs { result in
            DispatchQueue.main.async {
                self.discoveredTVs = result
                self.isSearching = false
            }
        }
    }
}
