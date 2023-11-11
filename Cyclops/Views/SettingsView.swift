// SettingsView.swift
// Created by José Duarte on 11/06/2023
// Copyright (c) 2023

import GRDBQuery
import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.Keys.AppTheme) private var appTheme = AppTheme.system.rawValue
    @AppStorage(UserDefaults.Keys.NumberOfStoriesPerPage) private var numberOfStoriesPerPage = UserDefaults.Defaults.NumberOfStoriesPerPage
    @AppStorage(UserDefaults.Keys.ShowNumberOfUpvotes) private var showNumberOfUpvotes = UserDefaults.Defaults.ShowNumberOfUpvotes
    @AppStorage(UserDefaults.Keys.ShowNumberOfComments) private var showNumberOfComments = UserDefaults.Defaults.ShowNumberOfComments
    @AppStorage(UserDefaults.Keys.WasOnboarded) private var wasOnboarded = UserDefaults.Defaults.WasOnboarded

    @Environment(\.appDatabase) private var appDatabase
    @Query(ViewedNumberRequest()) private var viewedNumber: Int

    @FocusState private var keyboardFocus: Bool

    private let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    private let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    private let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

    var feed: some View {
        Section {
            HStack {
                Label("Stories per page", systemImage: "newspaper")
                    .foregroundColor(.primary)
                    .scaledToFill()
                Spacer()
                Slider(value: $numberOfStoriesPerPage, in: 10 ... 50, step: 1) {
                    Text("Number of stories to fetch")
                }
                Text("\(Int(numberOfStoriesPerPage))")
            }

            Toggle(isOn: $showNumberOfUpvotes) {
                Label("Show upvote count", systemImage: "hand.thumbsup.fill")
            }
            .tint(.blue)
            .foregroundStyle(.primary)

            Toggle(isOn: $showNumberOfComments) {
                Label("Show comment count", systemImage: "bubble.left.and.text.bubble.right.fill")
            }
            .tint(.blue)
            .foregroundStyle(.primary)
        } header: {
            Text("Feed")
        } footer: {
            Text("Change how your Cyclops feed looks.")
        }
    }
    
    var theme: some View {
        Section {
            Picker(selection: $appTheme) {
                ForEach(AppTheme.allCases) { item in
                    Text(item.name).tag(item.rawValue)
                }
            } label: {
                Label("Color Theme", systemImage: "paintpalette")
            }
            .foregroundStyle(.primary)
        } header: {
            Text("Theme")
        } footer: {
            Text("Change how Cyclops looks.")
        }
    }
    
    var tutorial: some View {
        Section {
            HStack {
                Button {
                    wasOnboarded = false
                } label: {
                    Label("Redo the onboarding process", systemImage: "restart")
                }
                .foregroundStyle(.primary)
            }
        } header: {
            Text("Tutorial")
        } footer: {
            Text("Go through the Cyclops tutorial again. Your bookmarks and settings will not be modified.")
        }
    }
    
    var stats: some View {
        Section {
            HStack {
                Label("Viewed stories", systemImage: "eye").foregroundStyle(.primary)
                Spacer()
                Text("\(viewedNumber)")
            }
            Button {
                Task { try! await appDatabase.deleteAllViewed() }
            } label: {
                Label("Delete viewed stories data", systemImage: "trash")
            }
            .foregroundStyle(.red)
        } header: {
            Text("Stats")
        } footer: {
            Text("Some stats so you can see how addicted to Hacker News you are.")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                List {
                    feed
                    theme
                    tutorial
                    stats
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Text("\(appName) \(appVersion) (\(buildNumber))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .textSelection(.enabled)
                }
            }
        }
        .onTapGesture {
            keyboardFocus = false
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.appDatabase, .empty())
    }
}
