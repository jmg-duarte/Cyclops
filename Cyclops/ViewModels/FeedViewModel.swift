// FeedViewModel.swift
// Created by José Duarte on 14/06/2023
// Copyright (c) 2023

import Combine
import Foundation
import GRDB
import GRDBQuery
import os
import SwiftUI

@MainActor
class FeedViewModel: ObservableObject {

    @AppStorage(UserDefaults.Keys.NumberOfStoriesPerPage) private(set) var pageSize = UserDefaults.Defaults.NumberOfStoriesPerPage

    @Published private(set) var state = State.loading
    // These two could use didSet if it wasn't for the fact thatsometimes,
    // we need to force-refresh the page to make refreshing actually get something new
    @Published private(set) var currentFeed: StoryKind
    @Published private(set) var currentPage: Int = 1

    private(set) var feedPages: [StoryKind: Int] = StoryKind.getPageMappings()
    private var maxPages: Int = 0

    private let loader: HackerNewsClient

    enum State {
        case loading
        case failed(Error)
        case loaded([Item])
    }

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FeedViewModel.self)
    )

    init(feed: StoryKind = .top, loader: HackerNewsClient) {
        self.currentFeed = feed
        self.loader = loader
    }
}

// MARK: - Feed Controls

extension FeedViewModel {
    var isLastPage: Bool {
        !((currentPage * Int(pageSize)) > maxPages)
    }

    var isFirstPage: Bool {
        currentPage <= 1
    }

    // The loadPage needs to run in the MainQueue since it triggers an UI update
    // https://forums.swift.org/t/is-there-a-way-to-execute-code-on-the-main-thread-inside-a-task/60097
    private func loadPage(_ storyKind: StoryKind, page: Int, refresh: Bool = false) async {
        if refresh {
            // Just clears the cache objects, doesn't need a loading screen
            loader.refreshStoryIDs(kind: storyKind)
        }

        withAnimation {
            state = .loading
        }

        do {
            let pageSize = Int(pageSize)
            let feed = try await loader.fetchFeed(kind: storyKind, from: (page - 1) * pageSize, limit: pageSize)

            withAnimation { state = .loaded(feed) }
        } catch {
            withAnimation { state = .failed(error) }
        }
    }

    @MainActor
    func switchFeed(feed: StoryKind) async {
        let newPage = feedPages[currentFeed]!
        await loadPage(feed, page: newPage)

        withAnimation {
            currentFeed = feed
            currentPage = newPage
        }
    }

    @MainActor
    func nextPage() async {
        guard !isLastPage else { return }
        feedPages[currentFeed]! += 1
        let newPage = feedPages[currentFeed]!
        await loadPage(currentFeed, page: newPage)
        withAnimation { currentPage = newPage }
    }

    @MainActor
    func previousPage() async {
        guard !isFirstPage else { return }
        feedPages[currentFeed]! -= 1
        let newPage = feedPages[currentFeed]!
        await loadPage(currentFeed, page: newPage)
        withAnimation { currentPage = newPage }
    }

    /// Reset the current page to 1, does not refresh the page.
    @MainActor
    func resetPage() async {
        feedPages[currentFeed] = 1
        let newPage = feedPages[currentFeed]!
        await loadPage(currentFeed, page: newPage)
        withAnimation { currentPage = newPage }
    }

    /// Reset the page to 1 and refresh the page.
    @MainActor
    func refreshPage() async {
        feedPages[currentFeed] = 1
        let newPage = feedPages[currentFeed]!
        await loadPage(currentFeed, page: newPage, refresh: true)
        withAnimation { currentPage = newPage }
    }
}

// MARK: - Mock error feed

extension FeedViewModel {
    private enum TestError: Error {
        case error
    }

    static var error: FeedViewModel {
        let vm = FeedViewModel(loader: TestHackerNewsClient())
        vm.state = .failed(TestError.error)
        return vm
    }
}
