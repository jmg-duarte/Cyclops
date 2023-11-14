// BookmarksView.swift
// Created by José Duarte on 18/06/2023
// Copyright (c) 2023

import GRDBQuery
import SwiftUI

struct BookmarksView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Query(BookmarkRequest()) private var bookmarks: [Item]
    @State private var itemDetail: Item?

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
                        ItemView(item: bookmark)
                            .contextMenu {
                                Button {
                                    Task { try! await appDatabase.deleteBookmark(bookmark.id) }
                                } label: {
                                    Label("Remove Bookmark", systemImage: "bookmark")
                                }
                                ShareLink(item: bookmark.url) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                Button {
                                    self.itemDetail = bookmark
                                } label: {
                                    Label("Details", systemImage: "ellipsis.circle")
                                }
                            }
                    }.onDelete { indexSet in
                        for index in indexSet {
                            // TODO: really bad style but this only happens to a single index at a time (that I know)
                            Task { try! await appDatabase.deleteBookmark(bookmarks[index].id) }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationBarTitle(Text("Bookmarks"), displayMode: .inline)
                .sheet(item: $itemDetail) { item in
                    // https://stackoverflow.com/a/63217450
                    BookmarkDetailsSheet(item: item)
                        .presentationDetents([.fraction(0.4)])
                }
            }
        }
    }
}

#Preview {
    BookmarksView()
        .environment(\.appDatabase, AppDatabase.demo())
}
