//
//  Feed.swift
//  HckrNews
//
//  Created by José Duarte on 08/06/2023.
//

import Foundation

protocol Feed: ObservableObject {
    var stories: [Item] { get }

    /// Get N items of the feed
    func getItems() async throws
}

@MainActor
class TopFeed: Feed {
    @Published public internal(set) var stories: [Item] = []

    func getItems() async throws {
        stories = try await HackerNewsClient().topStories(limit: 10)
    }
}

@MainActor
class NewFeed: Feed {
    @Published public internal(set) var stories: [Item] = []

    func getItems() async throws {
        stories = try await HackerNewsClient().newStories(limit: 10)
    }
}

@MainActor
class BestFeed: Feed {
    @Published public internal(set) var stories: [Item] = []

    func getItems() async throws {
        stories = try await HackerNewsClient().bestStories(limit: 10)
    }
}

@MainActor
class MockFeed: Feed {
    @Published public internal(set) var stories: [Item] = []

    func getItems() async throws {
        stories = Item.sampleData
    }
}
