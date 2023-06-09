//
//  HckrNewsTests.swift
//  HckrNewsTests
//
//  Created by José Duarte on 08/06/2023.
//

@testable import HckrNews
import XCTest

final class HckrNewsTests: XCTestCase {
    func testNewsDecode() throws {
        let decoder = JSONDecoder()
        let news = try decoder.decode(Item.self, from: test_story)

        XCTAssertEqual(news.id, 8863)
        XCTAssertEqual(news.title, "My YC app: Dropbox - Throw away your USB drive")
        XCTAssertEqual(news.url, URL(string: "http://www.getdropbox.com/u/2/screencast.html")!)
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
