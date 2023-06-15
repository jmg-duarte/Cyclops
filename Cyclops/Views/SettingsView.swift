// SettingsView.swift
// Created by José Duarte on 11/06/2023
// Copyright (c) 2023

import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.Keys.NumberOfStoriesPerPage) private var numberOfStoriesPerPage: Double = 10

    let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

    var body: some View {
        NavigationView {
            Form {
                List {
                    Section("Stories") {
                        HStack {
                            Text("Stories per page")
                            Slider(value: $numberOfStoriesPerPage, in: 10 ... 50, step: 1) {
                                Text("Number of stories to fetch")
                            }
                            Text("\(Int(numberOfStoriesPerPage))")
                        }
                    }
                }
            }.navigationTitle("Settings")
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
    }
}
