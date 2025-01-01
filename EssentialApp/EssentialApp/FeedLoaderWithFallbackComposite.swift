//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 01/01/25.
//

import EssentialFeed

public final class FeedLoaderWithFallbackComposite: FeedLoader {
    let primary: FeedLoader
    let fallback: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
                case .success:
                    completion(result)
                    
                case .failure:
                    self?.fallback.load(completion: completion)
            }
        }
    }
}
