// CyclopsApp.swift
// Created by José Duarte on 20/06/2023
// Copyright (c) 2023

import SwiftUI
import GRDB
import GRDBQuery

@main
struct HckrNewsApp: App {
    @Environment(\.colorScheme) private var colorScheme

    // Tap for refresh
    // https://stackoverflow.com/a/65048085
    @State private var selection = 0
    private var selectionWrapper: Binding<Int> {
        Binding(
            get: { self.selection },
            set: {
                if $0 == self.selection {
                    self.feedViewModel.resetPage()
                }
                self.selection = $0
            }
        )
    }

    @StateObject private var networkMonitor = NetworkMonitor()
    @AppStorage(UserDefaults.Keys.AppTheme) private var appTheme: AppTheme = UserDefaults.Defaults.AppTheme

    private var selectedAppTheme: ColorScheme? {
        switch appTheme {
        case .system: return .none
        case .light: return .light
        case .dark: return .dark
        }
    }

    let hnClient: HackerNewsClient
    let feedViewModel: FeedViewModel

    init() {
        self.hnClient = HTTPHNClient()
        self.feedViewModel = FeedViewModel(loader: hnClient)
    }

    var body: some Scene {
        WindowGroup {
            TabView(selection: selectionWrapper) {
                FeedView(vm: feedViewModel)
                    .tabItem {
                        Label("Feed", systemImage: "newspaper")
                    }
                    .environmentObject(networkMonitor)
                    .tag(0)
                BookmarksView()
                    .tabItem {
                        Label("Bookmarks", systemImage: "bookmark")
                    }
                    .tag(1)
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(2)
            }
            .preferredColorScheme(selectedAppTheme)
            .environment(\.appDatabase, .shared)
        }
    }
}

private struct AppDatabaseKey: EnvironmentKey {
    static var defaultValue: AppDatabase { .empty() }
}

extension EnvironmentValues {
    var appDatabase: AppDatabase {
        get { self[AppDatabaseKey.self] }
        set { self[AppDatabaseKey.self] = newValue }
    }
}

extension Query where Request.DatabaseContext == AppDatabase {
    init (_ request: Request) {
        self.init(request, in: \.appDatabase)
    }
}
