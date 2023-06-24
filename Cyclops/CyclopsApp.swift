// CyclopsApp.swift
// Created by José Duarte on 20/06/2023
// Copyright (c) 2023

import SwiftUI

@main
struct HckrNewsApp: App {
    @Environment(\.colorScheme) private var colorScheme

    @State var appFinishedLoading: Bool = false

    @StateObject private var dataController = PersistenceController()
    @StateObject private var networkMonitor = NetworkMonitor()
    @AppStorage(UserDefaults.Keys.AppTheme) private var appTheme: AppTheme = UserDefaults.Defaults.AppTheme

    private var selectedAppTheme: ColorScheme? {
        switch appTheme {
        case .system: return .none
        case .light: return .light
        case .dark: return .dark
        }
    }

    let hnClient = HTTPHNClient()

    var body: some Scene {
        WindowGroup {
            TabView {
                FeedView(vm: FeedViewModel(feed: .top, loader: hnClient)).tabItem {
                    Label("Feed", systemImage: "newspaper")
                }
                .environmentObject(networkMonitor)
                BookmarksView()
                    .tabItem {
                        Label("Bookmarks", systemImage: "bookmark")
                    }
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                SettingsView().tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .preferredColorScheme(selectedAppTheme)
            .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
