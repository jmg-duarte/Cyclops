// HackerNewsClient.swift
// Created by José Duarte on 12/06/2023
// Copyright (c) 2023

import Foundation

protocol HackerNewsClient {
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
}
