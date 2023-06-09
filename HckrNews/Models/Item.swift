//
//  NewsItem.swift
//  HckrNews
//
//  Created by José Duarte on 08/06/2023.
//

import Foundation

/// An HackerNews item.
/// For more information, see: https://github.com/HackerNews/API
struct Item: Identifiable, Codable {
    // NOTE: For now, item is good enough to retrieve everything, but in the future,
    // a decoder based on the ItemType could be a nice improvement

    let id: Int
    let type: ItemType

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
    var time: Int? = nil
    var title: String? = nil
    var url: URL? = nil

    var timeAgo: Int? {
        guard time != nil else { return nil }

        let itemPublishUnixTime = Double(time!)
        let currentUnixTime = NSDate().timeIntervalSince1970
        let delta = currentUnixTime - itemPublishUnixTime

        return Int(delta)
    }

    var timeAgoWithUnits: String? {
        if let timeAgo = timeAgo {
            if timeAgo < 60 {
                let plural = timeAgo != 1 ? "s" : ""
                return "\(timeAgo) second\(plural) ago"
            }
            if timeAgo < 3600 {
                let minutes = timeAgo / 60
                let plural = minutes != 1 ? "s" : ""
                return "\(timeAgo / 60) minute\(plural) ago"
            }
            if timeAgo < 86400 {
                let hours = timeAgo / 60 / 60
                let plural = hours != 1 ? "s" : ""
                return "\(hours) hour\(plural) ago"
            }
            let days = timeAgo / 60 / 60 / 24
            let plural = days != 1 ? "s" : ""
            return "\(days) day\(plural) ago"
        }
        return nil
    }
}

extension Item {
    static var sampleData = [
        Item(
            id: 36_257_963,
            type: .story,
            by: "agluszak",
            descendants: 30,
            kids: [36_259_227, 36_258_965, 36_259_124, 36_258_940, 36_259_245, 36_259_006, 36_259_291, 36_258_787, 36_259_125, 36_259_209, 36_258_967, 36_258_958, 36_258_937],
            score: 74,
            time: 1_686_319_411,
            title: "OpenMW: Open-source TES3: Morrowind reimplementation",
            url: URL(string: "https://gitlab.com/OpenMW/openmw")!
        ),
        Item(
            id: 36_257_255,
            type: .story,
            by: "sohkamyung",
            descendants: 30,
            kids: [36_257_754, 36_257_977, 36_258_988, 36_258_451, 36_259_350, 36_258_334, 36_258_289, 36_257_904, 36_257_721],
            score: 75,
            time: 1_686_315_980,
            title: "Gravitational Machines",
            url: URL(string: "https://arxiv.org/abs/2305.10470")!
        ),
        Item(
            id: 36_246_547,
            type: .story,
            by: "sethbannon",
            descendants: 53,
            kids: [36_257_006, 36_259_384, 36_257_444, 36_259_215, 36_257_765, 36_257_802, 36_257_087, 36_257_058, 36_258_987, 36_256_911, 36_259_137, 36_258_422, 36_257_256, 36_257_229, 36_257_227, 36_256_895, 36_257_318],
            score: 258,
            time: 1_686_249_407,
            title: "Average color of the NYC sky every 5 minutes",
            url: URL(string: "https://nskyc.com/")!
        ),
    ]
}

/// An item's type.
// NOTE: "Type" cannot be the name of this enum
enum ItemType: String, CaseIterable, Codable {
    case job
    case story
    case comment
    case poll
    case pollopt
}
