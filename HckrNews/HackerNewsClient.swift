//
//  HackerNewsClient.swift
//  HckrNews
//
//  Created by José Duarte on 08/06/2023.
//

import Foundation

class HackerNewsClient {
    private static let hackerNewsAPIv0 = URL(string: "https://hacker-news.firebaseio.com/v0/")!
    private static let topStoriesURL = URL(string: "topstories.json", relativeTo: hackerNewsAPIv0)!

    private let downloader: any HTTPDataDownloader

    init(downloader: any HTTPDataDownloader = URLSession.shared) {
        self.downloader = downloader
    }

    private lazy var decoder: JSONDecoder = .init()

    var topStoriesIDs: [Int] {
        get async throws {
            let data = try await downloader.httpData(from: HackerNewsClient.topStoriesURL)
            let topStories = try decoder.decode([Int].self, from: data)
            return topStories
        }
    }

    func itemURL(id: Int) -> URL {
        return URL(string: "item/\(id).json", relativeTo: HackerNewsClient.hackerNewsAPIv0)!
    }

    func story(id: Int) async throws -> Item {
        let url = itemURL(id: id)
        let data = try await downloader.httpData(from: url)
        let story = try decoder.decode(Item.self, from: data)
        return story
    }

    func topStories(limit: Int) async throws -> [Item] {
        let topStoriesIDs = try await topStoriesIDs
        var topStories: [Item] = []
        for id in topStoriesIDs[0 ... limit] {
            let story = try await story(id: id)
            topStories.append(story)
        }
        return topStories
    }
}
