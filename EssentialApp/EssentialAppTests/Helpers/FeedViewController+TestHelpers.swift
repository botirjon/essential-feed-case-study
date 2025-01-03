//
//  FeedViewController+TestHelpers.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 03/01/25.
//

import UIKit
import EssentialFeediOS

extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach({ target in
            refreshControl?
                .actions(forTarget: target, forControlEvent: .valueChanged)?
                .forEach({ action in
                    fake.addTarget(target, action: Selector(action), for: .valueChanged)
                })
        })
        
        refreshControl = fake
    }
    
    func simulateViewAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlWithFakeForiOS17Support()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else { return nil }
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    @discardableResult
    func simulateFeedImageVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageVisible(at: index)?.renderedImage
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at index: Int) -> FeedImageCell? {
        let view = simulateFeedImageVisible(at: index)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
        return view
    }
    
    func simulateFeedImageViewNearVisible(at row: Int = 0) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int = 0) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    var errorMessage: String? {
        errorView.message
    }
    
    func simulateTapOnErrorMessage() {
        errorView.button.simulateTouchUpInside()
    }
}


private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing: Bool = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
