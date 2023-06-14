// HckrNewsApp.swift
// Created by José Duarte on 07/06/2023
// Copyright (c) 2023

import SwiftUI


@main
struct HckrNewsApp: App {
    @StateObject var networkMonitor = NetworkMonitor()
    
    let hnClient = HTTPHNClient()

    var body: some Scene {
        WindowGroup {
            TabView {
                FeedView(vm: FeedViewModel(feed:.top,  loader: hnClient)).tabItem {
                    Label("Top", systemImage: "chart.line.uptrend.xyaxis")
                }
                .environmentObject(networkMonitor)
                FeedView(vm: FeedViewModel(feed:.new, loader: hnClient)).tabItem {
                    Label("New", systemImage: "newspaper.fill")
                }
                .environmentObject(networkMonitor)
                FeedView(vm: FeedViewModel(feed:.best, loader: hnClient)).tabItem {
                    Label("Best", systemImage: "trophy.fill")
                }
                .environmentObject(networkMonitor)
                SettingsView().tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
    }
}
