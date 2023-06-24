// FeedView.swift
// Created by José Duarte on 20/06/2023
// Copyright (c) 2023

import Foundation
import os
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct FeedView: View {
    @State private var errorWrapper: ErrorWrapper?
    @State private var isShowingNavigationSheet: Bool = false
    @State private var isShowingShareLink: Bool = false

    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject var vm: FeedViewModel

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FeedView.self)
    )

    private func saveBookmark(item: Item) {
        let bookmark = Bookmark(context: viewContext)
        bookmark.id = Int64(item.id)
        bookmark.time = Int64(item.time!)
        bookmark.title = item.title
        bookmark.url = item.url
        try? viewContext.save()
    }

    var body: some View {
        if networkMonitor.isConnected {
            NavigationStack {
                switch vm.state {
                case .loading:
                    ProgressView()
                        .navigationBarTitle(Text("\(vm.currentFeed.rawValue.capitalized) Stories"), displayMode: .inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Button {
                                    isShowingNavigationSheet = true
                                } label: {
                                    Text("\(vm.currentFeed.rawValue.capitalized) Stories").bold()
                                    Image(systemName: "chevron.down")
                                        .imageScale(.small)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                case .failed:
                    // TODO: handle this
                    Text("ups")
                case let .loaded(feed):
                    List {
                        ForEach(feed) { item in
                            // Force unwrap should be safe because news always have titles and time
                            ItemView(id: item.id, url: item.url, title: item.title!, time: item.time!)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        saveBookmark(item: item)
                                    } label: {
                                        Label("Bookmark", systemImage: "bookmark.fill")
                                    }
                                    .tint(.blue)
                                }
                                .contextMenu {
                                    Button {
                                        saveBookmark(item: item)
                                    } label: {
                                        Label("Bookmark", systemImage: "bookmark")
                                    }
                                    ShareLink(item: item.url) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                        }
                    }
                    .toolbar {
                        if !vm.isFirstPage {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    Task {
                                        await vm.previousPage()
                                    }
                                } label: {
                                    Image(systemName: "chevron.left")
                                    Text("Page \(vm.currentPage - 1)")
                                }
                                .accessibilityHint(Text("Moves to the previous page"))
                            }
                        }
                        ToolbarItem(placement: .principal) {
                            Button {
                                isShowingNavigationSheet = true
                            } label: {
                                Text("\(vm.currentFeed.rawValue.capitalized) Stories").bold()
                                Image(systemName: "chevron.down")
                                    .imageScale(.small)
                            }
                            .buttonStyle(.plain)
                        }
                        if !vm.isLastPage {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    Task {
                                        await vm.nextPage()
                                    }
                                } label: {
                                    Text("Page \(vm.currentPage + 1)")
                                    Image(systemName: "chevron.right")
                                }
                                .accessibilityHint(Text("Moves to the next page"))
                            }
                        }
                    }
                    .navigationBarTitle(Text(""), displayMode: .inline)
                    .listStyle(.plain)
                    .sheet(isPresented: $isShowingNavigationSheet, onDismiss: { isShowingNavigationSheet = false }) {
                        FeedSelectionSheet(feedViewModel: vm, isShowing: $isShowingNavigationSheet)
                            .presentationDetents([.medium])
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
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
