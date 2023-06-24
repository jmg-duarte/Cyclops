// FeedSelectionSheet.swift
// Created by José Duarte on 24/06/2023
// Copyright (c) 2023

import SwiftUI

struct FeedSelectionSheet: View {
    @ObservedObject var feedViewModel: FeedViewModel
    @Binding var isShowing: Bool
    var body: some View {
        List {
            Section {
                Button {
                    Task { await feedViewModel.switchFeed(feed: .top) }
                    isShowing = false
                } label: {
                    Label("Top", systemImage: "chart.bar.fill")
                }
                Button {
                    Task { await feedViewModel.switchFeed(feed: .new) }
                    isShowing = false
                } label: {
                    Label("New", systemImage: "newspaper.fill")
                }
                Button {
                    Task { await feedViewModel.switchFeed(feed: .best) }
                    isShowing = false
                } label: {
                    Label("Best", systemImage: "trophy.fill")
                }
            }
            /*
             Section {
                 Label("Bookmarks", systemImage: "bookmark.fill")
             }
             Section {
                 Label("Settings", systemImage: "gear")
             }
              */
        }
    }
}

struct FeedSelectionSheet_Previews: PreviewProvider {
    static let client = TestHackerNewsClient()
    static let vm = FeedViewModel(feed: .top, loader: client)
    static var previews: some View {
        FeedSelectionSheet(feedViewModel: vm, isShowing: .constant(true))
    }
}
