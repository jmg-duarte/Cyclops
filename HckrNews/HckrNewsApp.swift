//
//  HckrNewsApp.swift
//  HckrNews
//
//  Created by José Duarte on 07/06/2023.
//

import SwiftUI

@main
struct HckrNewsApp: App {
    @StateObject public var topFeed: TopFeed = .init()
    @StateObject public var newFeed: NewFeed = .init()
    @StateObject public var bestFeed: BestFeed = .init()

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(title: "Top Stories", feed: topFeed).tabItem {
                    Label("Top", systemImage: "chart.line.uptrend.xyaxis")
                }
                ContentView(title: "New Stories", feed: newFeed).tabItem {
                    Label("New", systemImage: "newspaper.fill")
                }
                ContentView(title: "Best Stories", feed: bestFeed).tabItem {
                    Label("Best", systemImage: "trophy.fill")
                }
            }
        }
    }
}
