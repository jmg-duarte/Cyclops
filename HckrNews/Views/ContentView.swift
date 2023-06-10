//
//  ContentView.swift
//  HckrNews
//
//  Created by José Duarte on 07/06/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject public var feed: TopFeed = .init()

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

            .navigationTitle(Text("Top Stories"))
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
        ContentView(feed: MockFeed())
    }
}
