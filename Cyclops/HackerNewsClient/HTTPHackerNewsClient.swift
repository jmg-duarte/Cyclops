// HackerNewsClient.swift
// Created by José Duarte on 08/06/2023
// Copyright (c) 2023

import Foundation
import os

enum StoryKind: String {
    case new
    case top
    case best
    // case ask
    // case show
    // case job
}

class HTTPHNClient: HackerNewsClient {
    private static let hackerNewsAPIv0 = URL(string: "https://hacker-news.firebaseio.com/v0/")!
    private static let topStoriesURL = URL(string: "topstories.json", relativeTo: hackerNewsAPIv0)!
    private static let newStoriesURL = URL(string: "newstories.json", relativeTo: hackerNewsAPIv0)!
    private static let bestStoriesURL = URL(string: "beststories.json", relativeTo: hackerNewsAPIv0)!

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: HTTPHNClient.self)
    )

    private let downloader: URLSession

    init(downloader: URLSession = URLSession.shared) {
        self.downloader = downloader
    }

    private lazy var decoder: JSONDecoder = .init()

    func fetchStoryIDs(kind: StoryKind) async throws -> [Int] {
        Self.logger.info("Loading story IDs [kind: \(kind.rawValue)]")
        let storiesURL: URL
        switch kind {
        case .new:
            storiesURL = HTTPHNClient.newStoriesURL
        case .top:
            storiesURL = HTTPHNClient.topStoriesURL
        case .best:
            storiesURL = HTTPHNClient.bestStoriesURL
        }
        let data = try await downloader.httpData(from: storiesURL)
        return try decoder.decode([Int].self, from: data)
    }

    func fetchStory(id: Int) async throws -> Item {
        let url = URL(string: "item/\(id).json", relativeTo: HTTPHNClient.hackerNewsAPIv0)!
        let data = try await downloader.httpData(from: url)
        let story = try decoder.decode(Item.self, from: data)
        return story
    }

    func fetchFeed(kind: StoryKind, from: Int, limit: Int) async throws -> [Item] {
        Self.logger.info("Loading top stories [page: \(from), limit: \(limit)]")
        let ids = try await fetchStoryIDs(kind: kind)

        let maxIndex = ids.count - 1
        let startIndex = min(from, maxIndex)
        let endIndex = min(startIndex + limit, maxIndex)
        
        Self.logger.info("Loading stories [from: \(startIndex), to: \(endIndex)]")
        var stories: [(Int, Item)] = try await withThrowingTaskGroup(of: (Int, Item).self) { group in
            var stories: [(Int, Item)] = []
            for (idx, id) in ids[startIndex...endIndex].enumerated() {
                group.addTask {
                    return try await (idx, self.fetchStory(id: id))
                }
            }
            while let (idx, story) = try await group.next() {
                stories.append((idx, story))
            }
            return stories
        }
        stories.sort {
            $0.0 < $1.0
        }
        return stories.map { $1 }
    }
}
