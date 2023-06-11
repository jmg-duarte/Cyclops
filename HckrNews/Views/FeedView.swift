// FeedView.swift
// Created by José Duarte on 07/06/2023
// Copyright (c) 2023

import SwiftUI

struct FeedView: View {
    @ObservedObject public var feed: Feed

    @State private var errorWrapper: ErrorWrapper?

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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {} label: { Image(systemName: "arrow.left") }.accessibilityHint(Text("Moves to the previous page"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {} label: { Image(systemName: "arrow.right") }.accessibilityHint(Text("Moves to the next page"))
                }
            }
            .task {
                do {
                    try await feed.getItems()
                } catch {
                    errorWrapper = ErrorWrapper(error: error, guidance: "Try to reload the app...")
                }
            }
            .refreshable {
                do {
                    try await feed.getItems()
                } catch {
                    errorWrapper = ErrorWrapper(error: error, guidance: "Try to reload the app...")
                }
            }
            .sheet(item: $errorWrapper) {
                feed.stories = []
            } content: {
                wrapper in
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
