// FeedView.swift
// Created by José Duarte on 14/06/2023
// Copyright (c) 2023

import Foundation
import os
import SwiftUI

struct FeedView: View {
    @State private var errorWrapper: ErrorWrapper?
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject var vm: FeedViewModel

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FeedView.self)
    )

    var body: some View {
        if networkMonitor.isConnected {
            NavigationStack {
                switch vm.state {
                case .loading:
                    ProgressView()
                        .navigationBarTitle(Text("\(vm.feed.rawValue.capitalized) Stories"), displayMode: .inline)
                case .failed:
                    Text("ups")
                case let .loaded(feed):
                    List {
                        ForEach(feed) { item in
                            // Force unwrap should be safe because news always have titles and time
                            ItemView(url: item.url, title:item.title!, time:item.time!)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {} label: {
                                    Label("Hide", systemImage: "eye.slash")
                                }
                            }
                        }
                    }
                    .navigationBarTitle(Text("\(vm.feed.rawValue.capitalized) Stories"), displayMode: .inline)
                    .listStyle(.plain)
                    .toolbar {
                        if !vm.isFirstPage {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    Task {
                                        await vm.previousPage()
                                    }
                                } label: {
                                    Image(systemName: "arrow.left")
                                    Text("Page \(vm.currentPage - 1)")
                                }
                                .accessibilityHint(Text("Moves to the previous page"))
                            }
                        }
                        if !vm.isLastPage {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    Task {
                                        await vm.nextPage()
                                    }
                                } label: {
                                    Text("Page \(vm.currentPage + 1)")
                                    Image(systemName: "arrow.right")
                                }
                                .accessibilityHint(Text("Moves to the next page"))
                            }
                        }
                    }
                }
            }
            .task { await vm.loadPage() }
        } else {
            OfflineView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let networkMonitor = NetworkMonitor()
    static let client = TestHackerNewsClient()
    static let vm = FeedViewModel(feed: .top, loader: client)
    static var previews: some View {
        Group {
            FeedView(vm: vm)
                .environmentObject(networkMonitor)
                .previewDisplayName("Inherited")
            FeedView(vm: vm)
                .environmentObject(networkMonitor)
                .previewDisplayName("Light Mode")
                .preferredColorScheme(.light)
            FeedView(vm: vm)
                .environmentObject(networkMonitor)
                .previewDisplayName("Dark Mode")
                .preferredColorScheme(.dark)
        }
    }
}
