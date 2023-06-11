// HckrNewsTests.swift
// Created by José Duarte on 08/06/2023
// Copyright (c) 2023

@testable import HckrNews
import XCTest

final class ItemDecodeTests: XCTestCase {
    /// Decode a "normal" story from HackerNews
    func testNewsDecode() throws {
        let storyJSON = """
            {
              "by" : "dhouston",
              "descendants" : 71,
              "id" : 8863,
              "kids" : [ 8952, 9224, 8917, 8884, 8887, 8943, 8869, 8958, 9005, 9671, 8940, 9067, 8908, 9055, 8865, 8881, 8872, 8873, 8955, 10403, 8903, 8928, 9125, 8998, 8901, 8902, 8907, 8894, 8878, 8870, 8980, 8934, 8876 ],
              "score" : 111,
              "time" : 1175714200,
              "title" : "My YC app: Dropbox - Throw away your USB drive",
              "type" : "story",
              "url" : "http://www.getdropbox.com/u/2/screencast.html"
            }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let story = try decoder.decode(Item.self, from: storyJSON)

        XCTAssertEqual(story.by, "dhouston")
        XCTAssertEqual(story.descendants, 71)
        XCTAssertEqual(story.id, 8863)
        XCTAssertEqual(story.kids, [8952, 9224, 8917, 8884, 8887, 8943, 8869, 8958, 9005, 9671, 8940, 9067, 8908, 9055, 8865, 8881, 8872, 8873, 8955, 10403, 8903, 8928, 9125, 8998, 8901, 8902, 8907, 8894, 8878, 8870, 8980, 8934, 8876])
        XCTAssertEqual(story.score, 111)
        XCTAssertEqual(story.time, 1_175_714_200)
        XCTAssertEqual(story.title, "My YC app: Dropbox - Throw away your USB drive")
        XCTAssertEqual(story.type, .story)
        XCTAssertEqual(story.url, URL(string: "http://www.getdropbox.com/u/2/screencast.html")!)
    }

    /// Decode an AskHN story
    func testDecodeAskHN() throws {
        let askJSON = """
            {
              "by" : "mr_o47",
              "descendants" : 114,
              "id" : 36253565,
              "kids" : [ 36277101, 36277605, 36272918, 36273256, 36279752, 36275827, 36273263, 36275937, 36272775, 36275830, 36276773, 36277452, 36273813, 36272599, 36275536, 36272855, 36277863, 36273227, 36272538, 36272973, 36275645, 36273482, 36277103, 36275955, 36275911, 36272903, 36272703, 36277754, 36273475, 36272932, 36276997, 36277574, 36272732, 36273667, 36272977, 36276279, 36272429 ],
              "score" : 149,
              "text" : "Hello HN,<p>Would love to hear from devs who started their YouTube channel and what was the journey like",
              "time" : 1686287974,
              "title" : "Ask HN: Advice on starting a YouTube channel?",
              "type" : "story"
            }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let askDecoded = try decoder.decode(Item.self, from: askJSON)

        XCTAssertEqual(askDecoded.by, "mr_o47")
        XCTAssertEqual(askDecoded.descendants, 114)
        XCTAssertEqual(askDecoded.id, 36_253_565)
        XCTAssertEqual(askDecoded.kids, [36_277_101, 36_277_605, 36_272_918, 36_273_256, 36_279_752, 36_275_827, 36_273_263, 36_275_937, 36_272_775, 36_275_830, 36_276_773, 36_277_452, 36_273_813, 36_272_599, 36_275_536, 36_272_855, 36_277_863, 36_273_227, 36_272_538, 36_272_973, 36_275_645, 36_273_482, 36_277_103, 36_275_955, 36_275_911, 36_272_903, 36_272_703, 36_277_754, 36_273_475, 36_272_932, 36_276_997, 36_277_574, 36_272_732, 36_273_667, 36_272_977, 36_276_279, 36_272_429])
        XCTAssertEqual(askDecoded.score, 149)
        XCTAssertEqual(askDecoded.text, "Hello HN,<p>Would love to hear from devs who started their YouTube channel and what was the journey like")
        XCTAssertEqual(askDecoded.time, 1_686_287_974)
        XCTAssertEqual(askDecoded.title, "Ask HN: Advice on starting a YouTube channel?")
        XCTAssertEqual(askDecoded.type, .story)

        XCTAssertEqual(askDecoded.url, URL(string: "https://news.ycombinator.com/item?id=\(askDecoded.id)")!)
    }
}

final class ItemTypeTests: XCTestCase {
    func testDecoding() throws {
        let decoder = JSONDecoder()

        for itemType in ItemType.allCases {
            let data = "\"\(itemType.rawValue)\"".data(using: .utf8)!
            let result = try decoder.decode(ItemType.self, from: data)
            XCTAssertEqual(result, itemType)
        }
    }

    func testEncoding() throws {
        let encoder = JSONEncoder()

        for itemType in ItemType.allCases {
            let result = try encoder.encode(itemType)
            let expected = "\"\(itemType.rawValue)\"".data(using: .utf8)!
            XCTAssertEqual(result, expected)
        }
    }
}
