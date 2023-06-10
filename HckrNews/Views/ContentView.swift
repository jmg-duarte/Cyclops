//
//  ContentView.swift
//  HckrNews
//
//  Created by José Duarte on 07/06/2023.
//

import SwiftUI

struct ContentView<T>: View where T: Feed {
    let title: String
    @ObservedObject public var feed: T

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
            .navigationTitle(Text(title))
            .listStyle(.plain)
            .task {
                do {
                    try await feed.getItems()
                } catch {
                    fatalError("Unimplemented")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(title: "Test Stories", feed: MockFeed())
    }
}
