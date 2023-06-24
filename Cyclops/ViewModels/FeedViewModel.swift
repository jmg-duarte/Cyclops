// FeedViewModel.swift
// Created by José Duarte on 14/06/2023
// Copyright (c) 2023

import Foundation
import os
import SwiftUI

@MainActor
class FeedViewModel: ObservableObject {
    enum State {
        case loading
        case failed(Error)
        case loaded([Item])
    }

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FeedViewModel.self)
    )

    @Published private(set) var state = State.loading

    @AppStorage(UserDefaults.Keys.NumberOfStoriesPerPage) private(set) var pageSize = UserDefaults.Defaults.NumberOfStoriesPerPage

    private var maxPages: Int = 0

    private(set) var feed: StoryKind

    @Published
    private var feedPages: [StoryKind: Int] = [
        .top: 1,
        .new: 1,
        .best: 1,
    ]

    @Published
    private(set) var currentPage: Int = 1

    private let loader: HackerNewsClient

    var isLastPage: Bool {
        !((currentPage * Int(pageSize)) > maxPages)
    }

    var isFirstPage: Bool {
        currentPage <= 1
    }

    init(feed: StoryKind, loader: HackerNewsClient) {
        self.feed = feed
        self.loader = loader
    }

    func loadPage() async {
        state = .loading
        let pageSize = Int(pageSize)
        do {
            Self.logger.debug("Loading page")
            let feed = try await loader.fetchFeed(kind: feed, from: (currentPage - 1) * pageSize, limit: pageSize)
            state = .loaded(feed)
            Self.logger.debug("Loaded page")
        } catch {
            state = .failed(error)
            Self.logger.debug("Error loading page")
        }
    }

    func switchFeed(feed: StoryKind) async {
        self.feed = feed
        updateCurrentPage()
        await loadPage()
    }

    func nextPage() async {
        if !isLastPage {
            feedPages[feed]! += 1
            updateCurrentPage()
            await loadPage()
        }
    }

    func previousPage() async {
        if !isFirstPage {
            feedPages[feed]! -= 1
            updateCurrentPage()
            await loadPage()
        }
    }

    func updateCurrentPage() {
        currentPage = feedPages[feed]!
    }
}
