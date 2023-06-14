//
//  FeedViewModel.swift
//  Cyclops
//
//  Created by José Duarte on 14/06/2023.
//

import Foundation
import SwiftUI
import os

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
    @Published private(set) var currentPage = 1
    
    @AppStorage(UserDefaults.Keys.NumberOfStoriesPerPage) private(set) var pageSize = 10
    
    private var maxPages: Int = 0
    
    let feed: StoryKind
    private let loader: HackerNewsClient
    
    
    var isLastPage: Bool {
        !((currentPage * pageSize) > maxPages)
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
    
    func nextPage() async {
        if !self.isLastPage {
            currentPage += 1
            await loadPage()
        }
    }
    
    func previousPage() async {
        if !self.isFirstPage {
            currentPage -= 1
            await loadPage()
        }
    }
}
