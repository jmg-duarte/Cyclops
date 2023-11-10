// SettingsView.swift
// Created by José Duarte on 11/06/2023
// Copyright (c) 2023

import GRDBQuery
import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.Keys.AppTheme) private var appTheme = AppTheme.system.rawValue
    @AppStorage(UserDefaults.Keys.NumberOfStoriesPerPage) private var numberOfStoriesPerPage: Double = UserDefaults.Defaults.NumberOfStoriesPerPage
    @AppStorage(UserDefaults.Keys.ShowNumberOfComments) private var showNumberOfComments = UserDefaults.Defaults.ShowNumberOfComments
    @AppStorage(UserDefaults.Keys.WasOnboarded) private var wasOnboarded = UserDefaults.Defaults.WasOnboarded

    private let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    private let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    private let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

    @Environment(\.appDatabase) private var appDatabase
    @Query(ViewedNumberRequest()) private var viewedNumber: Int

    var body: some View {
        NavigationView {
            Form {
                List {
                    Section("Feed settings") {
                        HStack {
                            Text("Stories per page")
                            Slider(value: $numberOfStoriesPerPage, in: 10 ... 50, step: 1) {
                                Text("Number of stories to fetch")
                            }
                            Text("\(Int(numberOfStoriesPerPage))")
                        }
                        Toggle(isOn: $showNumberOfComments) {
                            Text("Show number of comments")
                        }.tint(.blue)
                    }
                    
                    Section("Theme") {
                        Picker(selection: $appTheme) {
                            ForEach(AppTheme.allCases) { item in
                                Text(item.name).tag(item.rawValue)
                            }
                        } label: {
                            Text("Color Theme")
                        }
                    }

                    Section("Stats") {
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
                    }
                    
                    Section("Tutorial") {
                        HStack {
                            Button {
                                wasOnboarded = false
                            } label: {
                                Label("Redo the onboarding process", systemImage: "restart")
                            }
                            .foregroundStyle(.primary)
                        }
                    }
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
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.appDatabase, .empty())
    }
}
