//
//  HNProvider.swift
//  Cyclops
//
//  Created by José Duarte on 12/06/2023.
//

import Foundation

@MainActor
class HNProvider: ObservableObject {
    @Published var items : [Item] = []
    
    let client: HNClient
    
    init (client: HNClient = HTTPHNClient()) {
        self.client = client
    }
    
    func fetchFeed(kind: StoryKind, from: Int, limit: Int) async throws {
        items = try await client.fetchFeed(kind: kind, from: from, limit: limit)
    }
}
