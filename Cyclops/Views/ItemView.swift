// ItemView.swift
// Created by José Duarte on 09/06/2023
// Copyright (c) 2023

import SwiftUI

struct ItemView: View {
    @State private var notBookmarked = true

    let url: URL
    let title: String
    let time: UnixEpoch

    // This needs a view model to interact with the persistence layer,
    // otherwise the code will become a mess

    var body: some View {
        HStack {
            Link(destination: url) { VStack(alignment: .leading) {
                Text(title).font(.headline).multilineTextAlignment(.leading)
                HStack {
                    Text(time.formattedTimeAgo).font(.caption)
                    Text("(\(url.host()!))").font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button {
                notBookmarked.toggle()
                // TODO: figure out the crossing animation
                /*
                 Button {
                     let bookmark = Bookmark(context: managedObjectContext)
                     bookmark.id = Int64(item.id)
                     bookmark.url = item.url
                     bookmark.title = item.title
                     try? managedObjectContext.save()
                 } label: {
                     Label("Bookmark", systemImage: "bookmark")
                 }.tint(.blue)
                  */
            } label: {
                notBookmarked ? Image(systemName: "bookmark") : Image(systemName: "bookmark.fill")
            }
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(
            url: Item.sampleData[0].url,
            title: Item.sampleData[0].title!,
            time: Item.sampleData[0].time!
        )
    }
}
