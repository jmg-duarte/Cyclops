// TestHackerNewsClient.swift
// Created by José Duarte on 12/06/2023
// Copyright (c) 2023

import Foundation

class TestHackerNewsClient: HackerNewsClient {
    func refreshStoryIDs(kind: StoryKind) {
        // No-op
    }
    
    func fetchStoryIDs(kind _: StoryKind) async throws -> [Int] {
        Item.sampleData.map { item in item.id }
    }

    func fetchStory(id _: Int) async throws -> Item {
        Item.sampleData[0]
    }

    func fetchFeed(kind _: StoryKind, from _: Int, limit _: Int) async throws -> [Item] {
        Item.sampleData
    }
}

// TODO: create an error client
