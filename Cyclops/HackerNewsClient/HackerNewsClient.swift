// HackerNewsClient.swift
// Created by José Duarte on 12/06/2023
// Copyright (c) 2023

import Foundation

protocol HackerNewsClient {
    // The cache detail might be too much for the protocol,
    // maybe a better API would be to provide cacheable and non-cacheable fetches
    ///  Clean the story IDs cache.
    func refreshStoryIDs(kind: StoryKind)
    
    /// Fetch story IDs off of the provided kind.
    /// - Parameters
    ///     - kind: The kind of feed to fetch stories off of.
    func fetchStoryIDs(kind: StoryKind) async throws -> [Int]

    /// Fetch an item from the given ID
    /// - Parameters:
    ///     - id: The item ID
    func fetchStory(id: Int) async throws -> Item

    /// Fetch a set of stories based on the given story kind.
    func fetchFeed(kind: StoryKind, from: Int, limit: Int) async throws -> [Item]
    
    
    // TODO: fix this crap later
    func checkStoriesInCache(kind: StoryKind) -> Bool
}
