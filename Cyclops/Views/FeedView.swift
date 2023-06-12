// FeedView.swift
// Created by José Duarte on 07/06/2023
// Copyright (c) 2023

import SwiftUI
import os

struct FeedView: View {
    
    
    let kind: StoryKind
    
    private let storyLimit = 500
    
    @State private var currentPage: Int = 1
    @State private var errorWrapper: ErrorWrapper?
    @EnvironmentObject var provider: HNProvider
    
    @AppStorage(UserDefaults.Keys.NumberOfStoriesPerPage)
    private(set) var numberOfStoriesPerPage: Double = 10
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FeedView.self)
    )
    
    func loadFeed() async {
        do {
            try await provider.fetchFeed(kind: kind, from: currentPage, limit: Int(numberOfStoriesPerPage))
        } catch {
            errorWrapper = ErrorWrapper(error: error, guidance: "Try to reload the app...")
        }
    }
    
    func isFirstPage() -> Bool {
        return currentPage <= 1
    }
    
    func isLastPage() -> Bool {
        return currentPage * Int(numberOfStoriesPerPage) > storyLimit
    }

    func previousPage() {
        if !isFirstPage() {
            currentPage -= 1
            Task { await loadFeed() }
        }
    }

    func nextPage() {
        // NOTE: for my future self, logic here should be "we don't want to move forward if we're supposed to have seen more than 500 posts (which is the API limit)
        if !isLastPage() {
            currentPage += 1
            Task { await loadFeed() }
        }
    }
    
    func resetPage() {
        currentPage = 1
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(provider.items) { item in
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
            .navigationTitle(Text("\(kind.rawValue.capitalized) Stories"))
            .listStyle(.plain)
            .toolbar {
                if !isFirstPage() {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: previousPage) {
                            Image(systemName: "arrow.left")
                            Text("Page \(currentPage-1)")
                        }
                        .accessibilityHint(Text("Moves to the previous page"))
                    }
                }
                if !isLastPage() {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: nextPage) {
                            Text("Page \(currentPage+1)")
                            Image(systemName: "arrow.right")
                        }
                        .accessibilityHint(Text("Moves to the next page"))
                    }
                }
            }
            .task { await loadFeed() }
            .refreshable {
                resetPage()
                await loadFeed()
            }
            .sheet(item: $errorWrapper) {
                provider.items = []
            } content: { wrapper in
                ErrorView(errorWrapper: wrapper)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let client = TestHackerNewsClient()
        let provider = HNProvider(client: client)
        FeedView(kind: .top).environmentObject(provider)
    }
}
