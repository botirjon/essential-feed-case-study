//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 11/12/24.
//

import Foundation



public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult {
                case .success:
                    self.cache(feed, with: completion)
                    
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store
            .insert(
                feed.toLocal(),
                timestamp: currentDate(),
                completion: { [weak self] insertionResult in
                    guard self != nil else { return }
                    
                    completion(insertionResult)
                }
            )
    }
}
extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retreive(
completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .failure(let error):
                    completion(.failure(error))
                    
                case let .success(.some(cache)) where FeedCachePolicy.validate(
                    cache.timestamp,
                    against: currentDate()
                ):
                    completion(.success(cache.feed.toModels()))
                    
                case .success:
                    completion(.success([]))
            }
        })
    }
}
extension LocalFeedLoader {
    public func validateCache() {
        store.retreive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .failure:
                    self.store.deleteCachedFeed { _ in }
                    
                case let .success(.some(cache)) where !FeedCachePolicy.validate(
                    cache.timestamp,
                    against: currentDate()
                ):
                    self.store.deleteCachedFeed { _ in }
                    
                case .success:
                    break
            }
        }
        
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map {
            LocalFeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map {
            FeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
    }
}
