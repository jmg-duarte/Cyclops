// FeedView.swift
// Created by José Duarte on 07/06/2023
// Copyright (c) 2023

import SwiftUI

struct FeedView: View {
    @ObservedObject public var feed: Feed

    @State private var currentPage: Int = 0
    @State private var errorWrapper: ErrorWrapper?

    @AppStorage(UserDefaults.Keys.NumberOfStoriesPerPage) private var numberOfStoriesPerPage: Double = 10

    func loadFeed(page: Int) async {
        do {
            try await feed.getItems(page: page, limit: Int(numberOfStoriesPerPage))
        } catch {
            errorWrapper = ErrorWrapper(error: error, guidance: "Try to reload the app...")
        }
    }

    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
            Task { await loadFeed(page: currentPage) }
        }
    }

    func nextPage() {
        let postsPerPage = Int(UserDefaults.standard.double(forKey: UserDefaults.Keys.NumberOfStoriesPerPage))
        // NOTE: for my future self, logic here should be "we don't want to move forward if we're supposed to have seen more than 500 posts (which is the API limit)
        if (currentPage + 1) * postsPerPage < 500 {
            currentPage += 1
            Task { await loadFeed(page: currentPage) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(feed.stories) { item in
                    ItemView(item: item)
                }
                .onDelete { _ in }
                .swipeActions(edge: .leading) {
                    Button {} label: {
                        Label("Bookmark", systemImage: "bookmark")
                    }.tint(.blue)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {} label: {
                        Label("Hide", systemImage: "eye.slash")
                    }
                }
            }
            .navigationTitle(Text("\(feed.kind.rawValue.capitalized) Stories"))
            .listStyle(.plain)
            .toolbar {
                if currentPage > 0 {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: previousPage) {
                            Image(systemName: "arrow.left")
                        }.accessibilityHint(Text("Moves to the previous page"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: nextPage) {
                        Image(systemName: "arrow.right")
                    }.accessibilityHint(Text("Moves to the next page"))
                }
            }
            .task { await loadFeed(page: currentPage) }
            .refreshable { await loadFeed(page: currentPage) }
            .sheet(item: $errorWrapper) {
                feed.stories = []
            } content: { wrapper in
                ErrorView(errorWrapper: wrapper)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(feed: Feed(kind: .test))
    }
}
