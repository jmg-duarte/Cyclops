//
//  TestHackerNewsClient.swift
//  Cyclops
//
//  Created by José Duarte on 12/06/2023.
//

import Foundation

class TestHackerNewsClient: HackerNewsClient {
    func fetchStoryIDs(kind: StoryKind) async throws -> [Int] {
        return Item.sampleData.map{ item in item.id }
    }
    
    func fetchStory(id: Int) async throws -> Item {
        return Item.sampleData[0]
    }
    
    func fetchFeed(kind: StoryKind, from: Int, limit: Int) async throws -> [Item] {
        return Item.sampleData
    }
}
