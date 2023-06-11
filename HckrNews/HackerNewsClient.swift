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

    func topStories(page: Int, limit: Int) async throws -> [Item] {
        let startIndex = page * Int(UserDefaults.standard.double(forKey: UserDefaults.Keys.NumberOfStoriesPerPage))
        let endIndex = startIndex + limit
        
        let topStoriesIDs = try await topStoriesIDs
        var topStories: [Item] = []
        
        for id in topStoriesIDs[startIndex ... endIndex] {
            let story = try await story(id: id)
            topStories.append(story)
        }
        return topStories
    }

    func newStories(page: Int, limit: Int) async throws -> [Item] {
        let startIndex = page * Int(UserDefaults.standard.double(forKey: UserDefaults.Keys.NumberOfStoriesPerPage))
        let endIndex = startIndex + limit
        
        let newStoriesIDs = try await newStoriesIDs
        var newStories: [Item] = []
        for id in newStoriesIDs[0 ... limit] {
            let story = try await story(id: id)
            newStories.append(story)
        }
        return newStories
    }

    func bestStories(page: Int, limit: Int) async throws -> [Item] {
        let startIndex = page * Int(UserDefaults.standard.double(forKey: UserDefaults.Keys.NumberOfStoriesPerPage))
        let endIndex = startIndex + limit
        
        let bestStoriesIDs = try await bestStoriesIDs
        var bestStories: [Item] = []
        for id in bestStoriesIDs[0 ... limit] {
            let story = try await story(id: id)
            bestStories.append(story)
        }
        return bestStories
    }
}
