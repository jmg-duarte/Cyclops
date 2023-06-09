//
//  Feed.swift
//  HckrNews
//
//  Created by José Duarte on 08/06/2023.
//

import Foundation

@MainActor
class TopFeed: ObservableObject {
    @Published public internal(set) var stories: [Item] = []

    func getItems() async throws {
        stories = try await HackerNewsClient().topStories(limit: 10)
    }
}

class MockFeed: TopFeed {
    override func getItems() async throws {
        stories = Item.sampleData
    }
}
