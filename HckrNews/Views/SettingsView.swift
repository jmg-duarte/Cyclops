//
//  SettingsView.swift
//  HckrNews
//
//  Created by José Duarte on 11/06/2023.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.Keys.NumberOfStoriesPerPage) private var numberOfStoriesPerPage: Double = 10

    var body: some View {
        Form {
            List {
                Section("Stories"){
                HStack {
                    Text("Stories per page")
                    Slider(value: $numberOfStoriesPerPage, in: 10 ... 50, step: 1) {
                        Text("Number of stories to fetch")
                    }
                    Text("\(Int(numberOfStoriesPerPage))")
                }}
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
