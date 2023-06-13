//
//  NetworkMonitor.swift
//  Cyclops
//
//  Created by José Duarte on 13/06/2023.
//

import Foundation
import Network


// Stolen from: https://morioh.com/p/68816b37881c
@MainActor
class NetworkMonitor: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    @Published private(set) var isConnected: Bool = true
    
    init() {
        monitor.pathUpdateHandler = {  path in
                self.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}


