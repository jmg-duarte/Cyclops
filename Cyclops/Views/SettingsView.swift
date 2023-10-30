// SettingsView.swift
// Created by José Duarte on 11/06/2023
// Copyright (c) 2023

import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.Keys.AppTheme) private var appTheme = AppTheme.system.rawValue
    @AppStorage(UserDefaults.Keys.NumberOfStoriesPerPage) private var numberOfStoriesPerPage: Double = UserDefaults.Defaults.NumberOfStoriesPerPage

    @Environment(\.modelContext) private var modelContext

    private let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    private let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    private let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

    private var viewedCount: Int {
        return (try? modelContext.fetchCount(FetchDescriptor<Viewed>())) ?? 0
    }

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
                            Label("Viewed stories", systemImage: "eye").foregroundColor(.black)
                            Spacer()
                            Text("\(viewedCount)")
                        }
                        Button {
                            try! modelContext.delete(model: Viewed.self)
                        } label: {
                            Label("Delete viewed stories data", systemImage: "trash")
                        }
                        .foregroundColor(.red)
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
    }
}
