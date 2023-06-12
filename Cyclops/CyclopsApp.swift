// HckrNewsApp.swift
// Created by José Duarte on 07/06/2023
// Copyright (c) 2023

import SwiftUI

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-an-appdelegate-to-a-swiftui-app
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if UserDefaults.standard.object(forKey: UserDefaults.Keys.NumberOfStoriesPerPage) == nil {
            UserDefaults.standard.set(10, forKey: UserDefaults.Keys.NumberOfStoriesPerPage)
        }

        return true
    }
}

@main
struct HckrNewsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject public var topFeed: Feed = .init(kind: .top)
    @StateObject public var newFeed: Feed = .init(kind: .new)
    @StateObject public var bestFeed: Feed = .init(kind: .best)

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
                SettingsView().tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
    }
}
