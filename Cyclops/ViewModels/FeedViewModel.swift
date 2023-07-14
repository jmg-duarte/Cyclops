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
    
    // These two could use didSet if it wasn't for the fact thatsometimes,
    // we need to force-refresh the page to make refreshing actually get something new
    @Published private(set) var currentFeed: StoryKind
    @Published private(set) var currentPage: Int = 1

    private let loader: HackerNewsClient

    var isLastPage: Bool {
        !((currentPage * Int(pageSize)) > maxPages)
    }

    var isFirstPage: Bool {
        currentPage <= 1
    }

    init(feed: StoryKind = .top, loader: HackerNewsClient) {
        self.currentFeed = feed
        self.loader = loader
    }
    
    // The loadPage needs to run in the MainQueue since it triggers an UI update
    // https://forums.swift.org/t/is-there-a-way-to-execute-code-on-the-main-thread-inside-a-task/60097
    @MainActor
    func loadPage(refresh: Bool = false) async {
        state = .loading
        let pageSize = Int(pageSize)
        if refresh {
            loader.refreshStoryIDs(kind: currentFeed)
        }
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

    func switchFeed(feed: StoryKind) {
        self.currentFeed = feed
        currentPage = feedPages[currentFeed]!
        Task { await loadPage() }
    }

    func nextPage() {
        if !isLastPage {
            feedPages[currentFeed]! += 1
            currentPage = feedPages[currentFeed]!
            Task { await loadPage() }
        }
    }

    func previousPage() {
        if !isFirstPage {
            feedPages[currentFeed]! -= 1
            currentPage = feedPages[currentFeed]!
            Task { await loadPage() }
        }
    }
    
    /// Reset the current page to 1, does not refresh the page.
    func resetPage() {
        feedPages[currentFeed] = 1
        currentPage = feedPages[currentFeed]!
        Task { await loadPage() }
    }
    
    /// Reset the page to 1 and refresh the page.
    func refreshPage() async {
        feedPages[currentFeed] = 1
        currentPage = feedPages[currentFeed]!
        await loadPage(refresh: true)
    }
}

private enum ViewModelTestError: Error {
    case error
}

extension FeedViewModel {
    static var error: FeedViewModel {
        let vm = FeedViewModel(loader: TestHackerNewsClient())
        vm.state = .failed(ViewModelTestError.error)
        return vm
    }
}
