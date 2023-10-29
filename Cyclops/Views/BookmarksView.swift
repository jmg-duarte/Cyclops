// BookmarksView.swift
// Created by José Duarte on 18/06/2023
// Copyright (c) 2023

import SwiftUI
import SwiftData

struct BookmarksView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.time, order: .reverse) private var bookmarks: [Item]
    
    var body: some View {
        NavigationStack {
            if bookmarks.isEmpty {
                Text("Swipe from left to right on an item to bookmark it!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .navigationBarTitle(Text("Bookmarks"), displayMode: .inline)
            } else {
                List {
                    ForEach(bookmarks) { bookmark in
                        ItemView(
                            id: Int(bookmark.id),
                            url: bookmark.url,
                            title: bookmark.title!,
                            time: Int(bookmark.time!)
                        )
                    }
                    // I wanted the slide to show a trash icon but this is the only way I could make it work
                    // The .slideActions seems to delete the item, reload the view but not update the request
                    // so when it takes out the bookmark again, it's been deleted and the unwrap fails
                    // The explanation may be incorrect but for now, it's the best I know of
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(bookmarks[index])
                        }
                    }
                }
                .listStyle(.plain)
                .navigationBarTitle(Text("Bookmarks"), displayMode: .inline)
            }
        }
    }

}

#Preview {
    BookmarksView()
}
