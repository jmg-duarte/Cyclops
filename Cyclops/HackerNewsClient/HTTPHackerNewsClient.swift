// HTTPHackerNewsClient.swift
// Created by José Duarte on 08/06/2023
// Copyright (c) 2023

import Foundation
import os

enum StoryKind: String {
    case new
    case top
    case best
    case ask
    case show
    case job

    var feedURL: URL {
        switch self {
        case .new:
            return HTTPHNClient.newStoriesURL
        case .top:
            return HTTPHNClient.topStoriesURL
        case .best:
            return HTTPHNClient.bestStoriesURL
        case .ask:
            return HTTPHNClient.askStoriesURL
        case .show:
            return HTTPHNClient.showStoriesURL
        case .job:
            return HTTPHNClient.jobStoriesURL
        }
    }
    
    static func getPageMappings() -> [Self: Int]{
        return [ .top: 1, .new: 1, .best: 1, .ask: 1, .show: 1, .job: 1 ]
    }
}

class HTTPHNClient: HackerNewsClient {
    private static let hackerNewsAPIv0 = URL(string: "https://hacker-news.firebaseio.com/v0/")!
    static let topStoriesURL = URL(string: "topstories.json", relativeTo: hackerNewsAPIv0)!
    static let newStoriesURL = URL(string: "newstories.json", relativeTo: hackerNewsAPIv0)!
    static let bestStoriesURL = URL(string: "beststories.json", relativeTo: hackerNewsAPIv0)!
    static let askStoriesURL = URL(string: "askstories.json", relativeTo: hackerNewsAPIv0)!
    static let showStoriesURL = URL(string: "showstories.json", relativeTo: hackerNewsAPIv0)!
    static let jobStoriesURL = URL(string: "jobstories.json", relativeTo: hackerNewsAPIv0)!

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: HTTPHNClient.self)
    )

    private let downloader: URLSession
    private let storyIDsCache: NSCache<NSString, CacheEntryObject<[Int]>> = NSCache()
    private let storyCache: NSCache<NSString, CacheEntryObject<Item>> = NSCache()
    private lazy var decoder: JSONDecoder = .init()

    init(downloader: URLSession = URLSession.shared) {
        self.downloader = downloader
    }
    
    func refreshStoryIDs(kind: StoryKind) {
        storyIDsCache.removeObject(forKey: kind.feedURL.absoluteString as NSString)
    }
    
    // Super dirty, this whole caching strategy needs to be improved
    // maybe SQLite works for this purpose (?)
    func checkStoriesInCache(kind: StoryKind) -> Bool {
        if let cached = storyIDsCache.object(forKey: kind.feedURL.absoluteString as NSString) {
            Self.logger.debug("Found cache entry [key: \(kind.feedURL.absoluteString)]")
            switch cached.entry {
            case .inProgress(_):
                return false
            case .ready(_):
                return true
            }
        }
        return false
    }

    func fetchStoryIDs(kind: StoryKind) async throws -> [Int] {
        Self.logger.debug("Loading story IDs [kind: \(kind.rawValue)]")
        let storiesURL: URL = kind.feedURL
        if let cached = storyIDsCache.object(forKey: storiesURL.absoluteString as NSString) {
            Self.logger.debug("Found cache entry [key: \(storiesURL.absoluteString)]")
            switch cached.entry {
            case let .inProgress(task):
                return try await task.value
            case let .ready(storyIDs):
                return storyIDs
            }
        }
        let task = Task<[Int], Error> {
            let data = try await downloader.httpData(from: storiesURL)
            return try decoder.decode([Int].self, from: data)
        }
        storyIDsCache.setObject(CacheEntryObject(entry: .inProgress(task)), forKey: storiesURL.absoluteString as NSString)
        do {
            let storyIDs = try await task.value
            storyIDsCache.setObject(CacheEntryObject(entry: .ready(storyIDs)), forKey: storiesURL.absoluteString as NSString)
            return storyIDs
        } catch {
            storyIDsCache.removeObject(forKey: storiesURL.absoluteString as NSString)
            throw error
        }
    }

    func fetchStory(id: Int) async throws -> Item {
        let url = URL(string: "item/\(id).json", relativeTo: HTTPHNClient.hackerNewsAPIv0)!
        if let cached = storyCache.object(forKey: url.absoluteString as NSString) {
            Self.logger.debug("Found cache entry [key: \(url.absoluteString)]")
            switch cached.entry {
            case let .inProgress(task):
                return try await task.value
            case let .ready(story):
                return story
            }
        }
        let task = Task<Item, Error> {
            let data = try await downloader.httpData(from: url)
            return try decoder.decode(Item.self, from: data)
        }
        storyCache.setObject(CacheEntryObject(entry: .inProgress(task)), forKey: url.absoluteString as NSString)
        do {
            let story = try await task.value
            storyCache.setObject(CacheEntryObject(entry: .ready(story)), forKey: url.absoluteString as NSString)
            return story
        } catch {
            storyCache.removeObject(forKey: url.absoluteString as NSString)
            throw error
        }
    }

    func fetchFeed(kind: StoryKind, from: Int, limit: Int) async throws -> [Item] {
        Self.logger.info("Loading top stories [from: \(from), limit: \(limit)]")
        let ids = try await fetchStoryIDs(kind: kind)

        let maxIndex = ids.count - 1
        let startIndex = min(from, maxIndex)
        let endIndex = min(startIndex + (limit - 1), maxIndex)

        Self.logger.info("Loading stories [from: \(startIndex), to: \(endIndex)]")
        var stories: [(Int, Item)] = try await withThrowingTaskGroup(of: (Int, Item).self) { group in
            var stories: [(Int, Item)] = []
            for (idx, id) in ids[startIndex ... endIndex].enumerated() {
                group.addTask {
                    Self.logger.debug("Fetching story [id: \(id)]")
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
