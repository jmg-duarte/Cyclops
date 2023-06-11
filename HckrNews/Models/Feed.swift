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

    private var numberOfStoriesPerPage: Int { Int(UserDefaults.standard.double(forKey: UserDefaults.Keys.NumberOfStoriesPerPage)) }

    init(kind: FeedKind) {
        self.kind = kind
    }

    func getItems() async throws {
        switch kind {
        case .top:
            stories = try await HackerNewsClient().topStories(limit: numberOfStoriesPerPage)
        case .new:
            stories = try await HackerNewsClient().newStories(limit: numberOfStoriesPerPage)
        case .best:
            stories = try await HackerNewsClient().bestStories(limit: numberOfStoriesPerPage)
        case .test:
            stories = Item.sampleData
        }
    }
}
