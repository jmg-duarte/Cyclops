// HackerNewsClient.swift
// Created by José Duarte on 08/06/2023
// Copyright (c) 2023

import Foundation

class HackerNewsClient {
    private static let hackerNewsAPIv0 = URL(string: "https://hacker-news.firebaseio.com/v0/")!
    private static let topStoriesURL = URL(string: "topstories.json", relativeTo: hackerNewsAPIv0)!
    private static let newStoriesURL = URL(string: "newstories.json", relativeTo: hackerNewsAPIv0)!
    private static let bestStoriesURL = URL(string: "beststories.json", relativeTo: hackerNewsAPIv0)!

    private let downloader: any HTTPDataDownloader

    init(downloader: any HTTPDataDownloader = URLSession.shared) {
        self.downloader = downloader
    }

    private lazy var decoder: JSONDecoder = .init()

    private func getStoriesIDs(from: URL) async throws -> [Int] {
        let data = try await downloader.httpData(from: from)
        let stories = try decoder.decode([Int].self, from: data)
        return stories
    }

    private func itemURL(id: Int) -> URL {
        URL(string: "item/\(id).json", relativeTo: HackerNewsClient.hackerNewsAPIv0)!
    }

    var topStoriesIDs: [Int] {
        get async throws {
            try await getStoriesIDs(from: HackerNewsClient.topStoriesURL)
        }
    }

    var newStoriesIDs: [Int] {
        get async throws {
            try await getStoriesIDs(from: HackerNewsClient.newStoriesURL)
        }
    }

    var bestStoriesIDs: [Int] {
        get async throws {
            try await getStoriesIDs(from: HackerNewsClient.bestStoriesURL)
        }
    }

    func story(id: Int) async throws -> Item {
        let url = itemURL(id: id)
        let data = try await downloader.httpData(from: url)
        let story = try decoder.decode(Item.self, from: data)
        return story
    }

    // FIXME: variable names in the following functions
    func topStories(limit: Int) async throws -> [Item] {
        let topStoriesIDs = try await topStoriesIDs
        var topStories: [Item] = []
        for id in topStoriesIDs[0 ... limit] {
            let story = try await story(id: id)
            topStories.append(story)
        }
        return topStories
    }

    func newStories(limit: Int) async throws -> [Item] {
        let topStoriesIDs = try await newStoriesIDs
        var topStories: [Item] = []
        for id in topStoriesIDs[0 ... limit] {
            let story = try await story(id: id)
            topStories.append(story)
        }
        return topStories
    }

    func bestStories(limit: Int) async throws -> [Item] {
        let topStoriesIDs = try await bestStoriesIDs
        var topStories: [Item] = []
        for id in topStoriesIDs[0 ... limit] {
            let story = try await story(id: id)
            topStories.append(story)
        }
        return topStories
    }
}
