//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Botirjon Nasridinov on 20/12/24.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(
        feedLoader: FeedLoader,
        imageLoader: FeedImageDataLoader
    ) -> FeedViewController {
        let presenter = FeedPresenter()
        let presentationAdapter = FeedLoaderPresentationAdapter(
            feedLoader: feedLoader,
            presenter: presenter
        )
        let refreshController = FeedRefreshViewController(
            delegate: presentationAdapter
        )
        let feedController = FeedViewController(refreshController: refreshController)
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        presenter.feedView = FeedViewAdapter(
            controller: feedController,
            imageLoader: imageLoader
        )
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> (
        [FeedImage]
    ) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed
                .map {
                    FeedImageCellController(
                        viewModel: FeedImageViewModel<UIImage>(
                            model: $0,
                            imageLoader: loader,
                            imageTransformer: UIImage.init
                        )
                    )
                }
        }
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel) {
        object?.display(viewModel: viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed
            .map {
                FeedImageCellController(
                    viewModel: FeedImageViewModel<UIImage>(
                        model: $0,
                        imageLoader: imageLoader,
                        imageTransformer: UIImage.init
                    )
                )
            }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter
    
    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }
    
    func didRequestFeedRefresh() {
        presenter.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
                case let .success(feed):
                    self?.presenter.didFinishLoadingFeed(with: feed)
                    
                case let .failure(error):
                    self?.presenter.didFinishLoadingFeed(with: error)
            }
        }
    }
}
