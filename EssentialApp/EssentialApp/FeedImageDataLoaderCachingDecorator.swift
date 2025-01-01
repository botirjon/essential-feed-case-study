//
//  FeedImageDataLoaderCachingDecorator.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 02/01/25.
//

import Foundation
import EssentialFeed

public final class FeedImageDataLoaderCachingDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCaching
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCaching) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any EssentialFeed.FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map({ data in
                self?.cache.saveIgnoringResult(data, for: url)
                return data
            }))
        }
    }
}

private extension FeedImageDataCaching {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}
