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

    private(set) var feedPages: [StoryKind: Int] = StoryKind.getPageMappings()
    @Published private(set) var currentFeed: StoryKind
    @Published private(set) var currentPage: Int = 1

    private let loader: HackerNewsClient

    var isLastPage: Bool {
        !((currentPage * Int(pageSize)) > maxPages)
    }

    var isFirstPage: Bool {
        currentPage <= 1
    }

    init(feed: StoryKind, loader: HackerNewsClient) {
        self.currentFeed = feed
        self.loader = loader
    }

    func loadPage() async {
        state = .loading
        let pageSize = Int(pageSize)
        do {
            Self.logger.debug("Loading page")
            let feed = try await loader.fetchFeed(kind: currentFeed, from: (currentPage - 1) * pageSize, limit: pageSize)
            state = .loaded(feed)
            Self.logger.debug("Loaded page")
        } catch {
            state = .failed(error)
            Self.logger.debug("Error loading page")
        }
    }

    func switchFeed(feed: StoryKind) async {
        self.currentFeed = feed
        updateCurrentPage()
        await loadPage()
    }

    func nextPage() async {
        if !isLastPage {
            feedPages[currentFeed]! += 1
            updateCurrentPage()
            await loadPage()
        }
    }

    func previousPage() async {
        if !isFirstPage {
            feedPages[currentFeed]! -= 1
            updateCurrentPage()
            await loadPage()
        }
    }

    func updateCurrentPage() {
        currentPage = feedPages[currentFeed]!
    }
}
