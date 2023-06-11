// HckrNewsApp.swift
// Created by José Duarte on 07/06/2023
// Copyright (c) 2023

import SwiftUI

@main
struct HckrNewsApp: App {
    @StateObject public var topFeed: Feed = Feed(kind:.top)
    @StateObject public var newFeed: Feed = Feed(kind:.new)
    @StateObject public var bestFeed: Feed = Feed(kind: .best)

    var body: some Scene {
        WindowGroup {
            TabView {
                FeedView(feed: topFeed).tabItem {
                    Label("Top", systemImage: "chart.line.uptrend.xyaxis")
                }
                FeedView(feed: newFeed).tabItem {
                    Label("New", systemImage: "newspaper.fill")
                }
                FeedView(feed: bestFeed).tabItem {
                    Label("Best", systemImage: "trophy.fill")
                }
            }
        }
    }
}
