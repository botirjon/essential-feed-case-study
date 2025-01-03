//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 23/12/24.
//

import Foundation

public protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

public protocol FeedView {
    func display(viewModel: FeedViewModel)
}

public protocol FeedErrorView {
    func display(viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    private let errorView: FeedErrorView
    
    public init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    public static var title: String {
        return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }
    
    public static var loadError: String {
        return NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Feed load error"
        )
    }
    
    public func didStartLoadingFeed() {
        errorView.display(viewModel: .noError)
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        errorView.display(viewModel: .noError)
        feedView.display(viewModel: FeedViewModel(feed: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(viewModel: .error(FeedPresenter.loadError))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
