//
//  FeedLoaderCachingDecorator.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 02/01/25.
//

import EssentialFeed

public final class FeedLoaderCachingDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCaching
    
    public init(decoratee: FeedLoader, cache: FeedCaching) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            })
        }
    }
}


private extension FeedCaching {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}
