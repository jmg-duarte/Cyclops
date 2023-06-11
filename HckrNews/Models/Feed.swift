// Feed.swift
// Created by José Duarte on 08/06/2023
// Copyright (c) 2023

import Foundation

enum FeedKind: String {
    case top
    case new
    case best
    case test
}

@MainActor
class Feed: ObservableObject {
    let kind: FeedKind
    let fetchStories: () async throws -> [Item]

    @Published public internal(set) var stories: [Item] = []

    init(kind: FeedKind) {
        let limit = 10
        self.kind = kind
        switch self.kind {
        case .top:
            fetchStories = { try await HackerNewsClient().topStories(limit: limit) }
        case .new:
            fetchStories = { try await HackerNewsClient().newStories(limit: limit) }
        case .best:
            fetchStories = { try await HackerNewsClient().bestStories(limit: limit) }
        case .test:
            fetchStories = { Item.sampleData }
        }
    }

    func getItems() async throws {
        stories = try await fetchStories()
    }
}
