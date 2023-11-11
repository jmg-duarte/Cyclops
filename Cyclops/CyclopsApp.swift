// CyclopsApp.swift
// Created by José Duarte on 20/06/2023
// Copyright (c) 2023

import GRDB
import GRDBQuery
import SwiftUI

@main
struct HckrNewsApp: App {
    @Environment(\.colorScheme) private var colorScheme

    // Tap for refresh
    // https://stackoverflow.com/a/65048085
    @State private var selection = 0
    private var selectionWrapper: Binding<Int> {
        Binding(
            get: { self.selection },
            set: { newValue in
                if newValue == self.selection {
                    Task { await self.feedViewModel.resetPage() }
                }
                withAnimation {
                    self.selection = newValue
                }
            }
        )
    }

    @StateObject private var networkMonitor = NetworkMonitor()
    @AppStorage(UserDefaults.Keys.AppTheme) private var appTheme = UserDefaults.Defaults.AppTheme
    @AppStorage(UserDefaults.Keys.WasOnboarded) private var wasOnboarded = UserDefaults.Defaults.WasOnboarded

    let feedViewModel = FeedViewModel(loader: HTTPHNClient())

    var body: some Scene {
        WindowGroup {
            if wasOnboarded {
                TabView(selection: selectionWrapper) {
                    FeedView()
                        .tabItem {
                            Label("Feed", systemImage: "newspaper")
                        }
                        .environmentObject(networkMonitor)
                        .environmentObject(feedViewModel)
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
                .preferredColorScheme(appTheme.colorScheme)
                .environment(\.appDatabase, .shared)
            } else {
                OnboardingView()
                    .preferredColorScheme(appTheme.colorScheme)
                    .environment(\.appDatabase, .shared)
            }
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
    init(_ request: Request) {
        self.init(request, in: \.appDatabase)
    }
}
