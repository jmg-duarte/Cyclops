// BookmarksView.swift
// Created by José Duarte on 18/06/2023
// Copyright (c) 2023

import GRDBQuery
import SwiftUI

struct BookmarksView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Query(BookmarkRequest()) private var bookmarks: [Item]

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
                            time: Int(bookmark.time!),
                            numberOfComments: bookmark.descendants ?? 0
                        )
                    }.onDelete { indexSet in
                        for index in indexSet {
                            // TODO: really bad style but this only happens to a single index at a time (that I know)
                            Task { try! await appDatabase.deleteBookmark(bookmarks[index].id) }
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
        .environment(\.appDatabase, AppDatabase.demo())
}
