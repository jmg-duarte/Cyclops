// ItemTests.swift
// Created by José Duarte on 08/06/2023
// Copyright (c) 2023

@testable import Cyclops
import XCTest

final class ItemTests: XCTestCase {
    /// Decode a "normal" story from HackerNews
    func testStoryDecode() throws {
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
    func testAskDecode() throws {
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

    func testDecodeComment() throws {
        let comment = """
            {
              "by" : "swighton",
              "id" : 36277101,
              "kids" : [ 36277437, 36277590, 36277204, 36277534, 36279015, 36278930, 36278500, 36277524 ],
              "parent" : 36253565,
              "text" : "I used to be a full time dev &#x2F; R&amp;D engineer. Now I basically do the same thing on YouTube (youtube.com&#x2F;stuffmadehere). The difference now is my R&amp;D-ing is directed at early stage prototypes that I think are interesting &#x2F; instructive, rather than what is best for an actual business, useful, or profitable.<p>Youtube is interesting because theres a constant source of numeric feedback on how you are doing (views &#x2F; subscribers &#x2F; watch time). Seeing these numbers change based on what you do can be incredibly addicting and it&#x27;s very easy to accidentally connect your personal happiness to those numbers. This is great if they are going up, but if they aren&#x27;t.... yeah. It&#x27;s also easy to get into a situation where you lean into &quot;what works&quot; over and over until you find yourself doing stuff that you don&#x27;t enjoy.<p>My advice would be to find a way to keep the numbers at arms length and focus on doing stuff that you enjoy. You definitely need the feedback of stats &#x2F; comments &#x2F; etc to get better, but you don&#x27;t wan to check it 10 times a day. Personally when I launch a video I will check a few times to ensure I didn&#x27;t screw up anything major, see if there is any useful feedback in comments, then I will check maybe the stats every week or two.",
              "time" : 1686447454,
              "type" : "comment"
            }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let decodedComment = try decoder.decode(Item.self, from: comment)

        XCTAssertEqual(decodedComment.by, "swighton")
        XCTAssertEqual(decodedComment.id, 36_277_101)
        XCTAssertEqual(decodedComment.kids, [36_277_437, 36_277_590, 36_277_204, 36_277_534, 36_279_015, 36_278_930, 36_278_500, 36_277_524])
        XCTAssertEqual(decodedComment.parent, 36_253_565)
        XCTAssertEqual(decodedComment.text, "I used to be a full time dev &#x2F; R&amp;D engineer. Now I basically do the same thing on YouTube (youtube.com&#x2F;stuffmadehere). The difference now is my R&amp;D-ing is directed at early stage prototypes that I think are interesting &#x2F; instructive, rather than what is best for an actual business, useful, or profitable.<p>Youtube is interesting because theres a constant source of numeric feedback on how you are doing (views &#x2F; subscribers &#x2F; watch time). Seeing these numbers change based on what you do can be incredibly addicting and it&#x27;s very easy to accidentally connect your personal happiness to those numbers. This is great if they are going up, but if they aren&#x27;t.... yeah. It&#x27;s also easy to get into a situation where you lean into &quot;what works&quot; over and over until you find yourself doing stuff that you don&#x27;t enjoy.<p>My advice would be to find a way to keep the numbers at arms length and focus on doing stuff that you enjoy. You definitely need the feedback of stats &#x2F; comments &#x2F; etc to get better, but you don&#x27;t wan to check it 10 times a day. Personally when I launch a video I will check a few times to ensure I didn&#x27;t screw up anything major, see if there is any useful feedback in comments, then I will check maybe the stats every week or two.")
        XCTAssertEqual(decodedComment.time, 1_686_447_454)
        XCTAssertEqual(decodedComment.type, .comment)
        XCTAssertEqual(decodedComment.url, URL(string: "https://news.ycombinator.com/item?id=\(decodedComment.id)")!)
    }

    func testDecodeJob() throws {
        let job = """
            {
              "by" : "ethanyu94",
              "id" : 36215816,
              "score" : 1,
              "time" : 1686070818,
              "title" : "Motion (YC W20) Is Hiring Front End Engineers",
              "type" : "job",
              "url" : "https://jobs.ashbyhq.com/motion/4f5f6a29-3af0-4d79-99a4-988ff7c5ba05?utm_source=hn"
            }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let decodedJob = try decoder.decode(Item.self, from: job)

        XCTAssertEqual(decodedJob.by, "ethanyu94")
        XCTAssertEqual(decodedJob.id, 36_215_816)
        XCTAssertEqual(decodedJob.score, 1)
        XCTAssertEqual(decodedJob.time, 1_686_070_818)
        XCTAssertEqual(decodedJob.title, "Motion (YC W20) Is Hiring Front End Engineers")
        XCTAssertEqual(decodedJob.type, .job)
        XCTAssertEqual(decodedJob.url, URL(string: "https://jobs.ashbyhq.com/motion/4f5f6a29-3af0-4d79-99a4-988ff7c5ba05?utm_source=hn")!)
    }

    func testDecodePoll() throws {
        let poll = """
            {
              "by" : "pg",
              "descendants" : 54,
              "id" : 126809,
              "kids" : [ 126822, 126823, 126917, 126993, 126824, 126934, 127411, 126888, 127681, 126818, 126816, 126854, 127095, 126861, 127313, 127299, 126859, 126852, 126882, 126832, 127072, 127217, 126889, 126875, 127535 ],
              "parts" : [ 126810, 126811, 126812 ],
              "score" : 47,
              "time" : 1204403652,
              "title" : "Poll: What would happen if News.YC had explicit support for polls?",
              "type" : "poll"
            }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let decodedPoll = try decoder.decode(Item.self, from: poll)

        XCTAssertEqual(decodedPoll.by, "pg")
        XCTAssertEqual(decodedPoll.descendants, 54)
        XCTAssertEqual(decodedPoll.id, 126_809)
        XCTAssertEqual(decodedPoll.kids, [126_822, 126_823, 126_917, 126_993, 126_824, 126_934, 127_411, 126_888, 127_681, 126_818, 126_816, 126_854, 127_095, 126_861, 127_313, 127_299, 126_859, 126_852, 126_882, 126_832, 127_072, 127_217, 126_889, 126_875, 127_535])
        XCTAssertEqual(decodedPoll.parts, [126_810, 126_811, 126_812])
        XCTAssertEqual(decodedPoll.score, 47)
        XCTAssertEqual(decodedPoll.time, 1_204_403_652)
        XCTAssertEqual(decodedPoll.title, "Poll: What would happen if News.YC had explicit support for polls?")
        XCTAssertEqual(decodedPoll.type, .poll)
        XCTAssertEqual(decodedPoll.url, URL(string: "https://news.ycombinator.com/item?id=\(decodedPoll.id)")!)
    }

    func testDecodePollOpt() throws {
        let pollOpt = """
            {
              "by" : "pg",
              "id" : 160705,
              "poll" : 160704,
              "score" : 335,
              "text" : "Yes, ban them; I'm tired of seeing Valleywag stories on News.YC.",
              "time" : 1207886576,
              "type" : "pollopt"
            }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let decodedPollOpt = try decoder.decode(Item.self, from: pollOpt)

        XCTAssertEqual(decodedPollOpt.by, "pg")
        XCTAssertEqual(decodedPollOpt.id, 160_705)
        XCTAssertEqual(decodedPollOpt.poll, 160_704)
        XCTAssertEqual(decodedPollOpt.score, 335)
        XCTAssertEqual(decodedPollOpt.text, "Yes, ban them; I'm tired of seeing Valleywag stories on News.YC.")
        XCTAssertEqual(decodedPollOpt.time, 1_207_886_576)
        XCTAssertEqual(decodedPollOpt.type, .pollopt)
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
}
