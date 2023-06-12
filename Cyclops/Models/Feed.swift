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

    @Published public internal(set) var stories: [Item] = []


    init(kind: FeedKind) {
        self.kind = kind
    }

    func getItems(page: Int, limit: Int) async throws {
        switch kind {
        case .top:
            stories = try await HackerNewsClient().topStories(page: page, limit: limit)
        case .new:
            stories = try await HackerNewsClient().newStories(page: page, limit: limit)
        case .best:
            stories = try await HackerNewsClient().bestStories(page: page, limit: limit)
        case .test:
            stories = Item.sampleData
        }
    }
}
