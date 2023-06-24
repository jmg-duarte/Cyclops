// Int+Time.swift
// Created by José Duarte on 18/06/2023
// Copyright (c) 2023

import Foundation

typealias UnixEpoch = Int

extension UnixEpoch {
    var timeAgo: Int {
        let itemPublishUnixTime = Double(self)
        let currentUnixTime = NSDate().timeIntervalSince1970
        let delta = currentUnixTime - itemPublishUnixTime

        return Int(delta)
    }

    var formattedTimeAgo: String {
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
}
