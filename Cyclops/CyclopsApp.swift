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
    
    @StateObject var hackerNewsProvider = HNProvider()
    @StateObject var networkMonitor = NetworkMonitor()

    var body: some Scene {
        WindowGroup {
            TabView {
                FeedView(kind:.top).tabItem {
                    Label("Top", systemImage: "chart.line.uptrend.xyaxis")
                }
                .environmentObject(hackerNewsProvider)
                .environmentObject(networkMonitor)
                FeedView(kind:.new).tabItem {
                    Label("New", systemImage: "newspaper.fill")
                }
                .environmentObject(hackerNewsProvider)
                .environmentObject(networkMonitor)
                FeedView(kind:.best).tabItem {
                    Label("Best", systemImage: "trophy.fill")
                }
                .environmentObject(hackerNewsProvider)
                .environmentObject(networkMonitor)
                SettingsView().tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
    }
}
