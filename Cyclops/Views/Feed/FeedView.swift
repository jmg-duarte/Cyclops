// FeedView.swift
// Created by José Duarte on 20/06/2023
// Copyright (c) 2023

import Foundation
import os
import SwiftData
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct FeedView: View {
    @State private var isShowingErrorAlert: Bool = false
    @State private var isShowingNavigationSheet: Bool = false
    @State private var itemDetail: Item? = nil
    @State private var shouldScrollToTop = false

    @Environment(\.appDatabase) private var appDatabase
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject var vm: FeedViewModel

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FeedView.self)
    )

    var progress: some View {
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
    }

    func loaded(feed: [Item]) -> some View {
        return ScrollViewReader { reader in
            List {
                ForEach(feed) { item in
                    // Force unwrap should be safe because news always have titles and time
                    ItemView(id: item.id, url: item.url, title: item.title!, time: item.time!)
                        .swipeActions(edge: .leading) {
                            Button {
                                Task { try! await appDatabase.saveBookmark(item) }
                            } label: {
                                Label("Bookmark", systemImage: "bookmark.fill")
                            }
                            .tint(.blue)
                        }
                        .contextMenu {
                            Button {
                                Task { try! await appDatabase.saveBookmark(item) }
                            } label: {
                                Label("Bookmark", systemImage: "bookmark")
                            }
                            ShareLink(item: item.url) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            Button {
                                self.itemDetail = item
                            } label: {
                                Label("Details", systemImage: "ellipsis.circle")
                            }
                        }
                }
            }
            .onChange(of: shouldScrollToTop) { _, _ in
                withAnimation
                {
                    reader.scrollTo(feed.first?.id)
                }
            }
        }
        
        .refreshable {
            await vm.refreshPage()
        }
        .toolbar {
            if !vm.isFirstPage {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Task { await vm.previousPage() }
                        shouldScrollToTop.toggle()
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
                        Task { await vm.nextPage() }
                        shouldScrollToTop.toggle()
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
        .sheet(item: $itemDetail) { item in
            // https://stackoverflow.com/a/63217450
            ItemDetailsSheet(item: item)
                .presentationDetents([.fraction(0.4)])
        }
    }

    var body: some View {
        if networkMonitor.isConnected {
            NavigationStack {
                switch vm.state {
                case .loading: progress
                case let .failed(error):
                    ErrorView(errorWrapper: ErrorWrapper(error: error, guidance: "Please report this error to the developer.\nYou can refresh the page to retry..."))
                        .refreshable {
                            await vm.refreshPage()
                        }
                        .navigationBarTitle(Text(""), displayMode: .inline)
                        .toolbar {
                            ToolbarItem {
                                Button {
                                    Task { await vm.refreshPage() }
                                } label: {
                                    Label("Refresh", systemImage: "arrow.circlepath")
                                }
                            }
                        }
                case let .loaded(feed):
                    loaded(feed: feed)
                }
            }
            // This runs the first page load
            .task { await vm.resetPage() }
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
        }
    }
}
