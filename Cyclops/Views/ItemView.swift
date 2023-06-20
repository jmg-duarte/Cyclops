// ItemView.swift
// Created by José Duarte on 09/06/2023
// Copyright (c) 2023

import SwiftUI
import CoreData

struct ItemView: View {
    let id: Int
    let url: URL
    let title: String
    let time: UnixEpoch

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Link(destination: self.url) {
                    Text(self.title).font(.headline).multilineTextAlignment(.leading)
                }
                HStack {
                    Text(self.time.formattedTimeAgo).font(.caption)
                    Text("(\(self.url.host()!))").font(.caption)
                }
            }
        }
        // Without this, the HStack will trigger all the "tappable" actions
        // See the following link for more information:
        // - https://stackoverflow.com/a/59402642
        .buttonStyle(.plain)
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(
            id: Item.sampleData[0].id,
            url: Item.sampleData[0].url,
            title: Item.sampleData[0].title!,
            time: Item.sampleData[0].time!
        )
    }
}
