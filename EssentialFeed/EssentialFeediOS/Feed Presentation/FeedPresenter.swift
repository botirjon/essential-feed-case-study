//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 23/12/24.
//

import Foundation
import EssentialFeed

public protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

public protocol FeedView {
    func display(viewModel: FeedViewModel)
}

public final class FeedPresenter {
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    
    public init(loadingView: FeedLoadingView, feedView: FeedView) {
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    public static var title: String {
        return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }
    
    public func didStartLoadingFeed() {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feed: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
