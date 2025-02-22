// Item.swift
// Created by José Duarte on 08/06/2023
// Copyright (c) 2023

import Foundation
import GRDB

/// An HackerNews item.
/// For more information, see: https://github.com/HackerNews/API
struct Item: Identifiable {
    // NOTE: For now, item is good enough to retrieve everything, but in the future,
    // a decoder based on the ItemType could be a nice improvement
    
    let id: Int
    let type: ItemType
    // The API may not return an URL, in which case, we default to the actual HN webpage
    let url: URL

    var by: String? = nil
    var dead: Bool? = nil
    var deleted: Bool? = nil
    var descendants: Int? = nil
    var kids: [Int]? = nil
    var parent: Int? = nil
    var parts: [Int]? = nil
    var poll: Int? = nil
    var score: Int? = nil
    var text: String? = nil
    var time: Int? = nil // This is (probably) only nil for pollopts
    var title: String? = nil // This is only nil for comments and friends

    
    static func postURL(_ id: Int) -> URL {
        URL(string: "https://news.ycombinator.com/item?id=\(id)")!
    }

    func postURL() -> URL {
        Item.postURL(id)
    }
}

extension Item: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case by
        case dead
        case deleted
        case descendants
        case kids
        case parent
        case parts
        case poll
        case score
        case text
        case time
        case title
        case url
    }
    
    init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            type = try values.decode(ItemType.self, forKey: .type)
            by = try? values.decode(String.self, forKey: .by)
            dead = try? values.decode(Bool.self, forKey: .dead)
            deleted = try? values.decode(Bool.self, forKey: .deleted)
            descendants = try? values.decode(Int.self, forKey: .descendants)
            kids = try? values.decode([Int].self, forKey: .kids)
            parent = try? values.decode(Int.self, forKey: .parent)
            parts = try? values.decode([Int].self, forKey: .parts)
            poll = try? values.decode(Int.self, forKey: .poll)
            score = try? values.decode(Int.self, forKey: .score)
            text = try? values.decode(String.self, forKey: .text)
            time = try? values.decode(Int.self, forKey: .time)
            title = try? values.decode(String.self, forKey: .title)
            url = (try? values.decode(URL.self, forKey: .url)) ?? Item.postURL(id)
        }
    
    func encode(to container: inout PersistenceContainer) throws {
        let jsonEncoder = JSONEncoder()
        container["id"] = id
        container["type"] = type
        container["by"] = by
        container["dead"] = dead
        container["deleted"] = deleted
        container["descendants"] = descendants
        container["kids"] = try! jsonEncoder.encode(kids)
        container["parent"] = parent
        container["parts"] = try! jsonEncoder.encode(kids)
        container["poll"] = poll
        container["score"] = score
        container["text"] = text
        container["time"] = time
        container["title"] = title
        container["url"] = url
    }
}

extension Item: FetchableRecord, PersistableRecord {
    fileprivate enum Columns {
        static let time = Column(CodingKeys.title)
    }
}

// MARK: - Item Database Requests

extension DerivableRequest<Item> {
    func orderedByTime() -> Self {
        order(Item.Columns.time.desc)
    }
}

// MARK: - Sample Data

extension Item {
    static var sampleData = [
        Item(
            id: 36_257_963,
            type: .story,
            url: URL(string: "https://gitlab.com/OpenMW/openmw")!,
            by: "agluszak",
            descendants: 30,
            kids: [36_259_227, 36_258_965, 36_259_124, 36_258_940, 36_259_245, 36_259_006, 36_259_291, 36_258_787, 36_259_125, 36_259_209, 36_258_967, 36_258_958, 36_258_937],
            score: 74,
            time: 1_686_319_411,
            title: "OpenMW: Open-source TES3: Morrowind reimplementation"
        ),
        Item(
            id: 36_257_255,
            type: .story,
            url: URL(string: "https://arxiv.org/abs/2305.10470")!,
            by: "sohkamyung",
            descendants: 30,
            kids: [36_257_754, 36_257_977, 36_258_988, 36_258_451, 36_259_350, 36_258_334, 36_258_289, 36_257_904, 36_257_721],
            score: 75,
            time: 1_686_315_980,
            title: "Gravitational Machines"
        ),
        Item(
            id: 36_246_547,
            type: .story,
            url: URL(string: "https://nskyc.com/")!,
            by: "sethbannon",
            descendants: 53,
            kids: [36_257_006, 36_259_384, 36_257_444, 36_259_215, 36_257_765, 36_257_802, 36_257_087, 36_257_058, 36_258_987, 36_256_911, 36_259_137, 36_258_422, 36_257_256, 36_257_229, 36_257_227, 36_256_895, 36_257_318],
            score: 258,
            time: 1_686_249_407,
            title: "Average color of the NYC sky every 5 minutes"
        ),
    ]
}

/// An item's type.
// NOTE: "Type" cannot be the name of this enum
enum ItemType: String, CaseIterable, Codable, DatabaseValueConvertible {
    case job
    case story
    case comment
    case poll
    case pollopt
}
