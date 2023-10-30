// ItemView.swift
// Created by José Duarte on 09/06/2023
// Copyright (c) 2023

import CoreData
import SwiftData
import SwiftUI

struct ItemView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext

    let id: Int
    let url: URL
    let title: String
    let time: UnixEpoch

static func viewedPredicate(_ id: Int) -> Predicate<Viewed> {
    return #Predicate<Viewed> { $0.id == id }
}

var viewed: [Viewed] {
    return (try? modelContext.fetch(
        FetchDescriptor(
            predicate: ItemView.viewedPredicate(id)
        ))) ?? []
}

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Link(destination: url) {
                    Text(title).font(.headline).multilineTextAlignment(.leading)
                }
                .environment(\.openURL, OpenURLAction { _ in
                    modelContext.insert(Viewed(id))
                    return .systemAction
                })
                HStack {
                    Text("\(time.formattedTimeAgo) (\(url.host()!))").font(.caption)
                }
            }
            if !viewed.isEmpty {
                Spacer()
                Image(systemName: "eye")
            }
        }
        // Without this, the HStack will trigger all the "tappable" actions
        // See the following link for more information:
        // - https://stackoverflow.com/a/59402642
        // Right now I need the whole HStack to be tappable but I'm leaving this
        // for whenever I want to add new buttons
        // .buttonStyle(.plain)
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
