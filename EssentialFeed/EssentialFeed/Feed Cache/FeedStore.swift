//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 11/12/24.
//

import Foundation

public enum CachedFeed {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    typealias RetreiveResult  = Result<CachedFeed, Error>
    typealias RetreiveCompletion = (RetreiveResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed
    /// - Parameter completion: A callback to be invoked after completion
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed
    /// - Parameters:
    ///   - feed: An array `LocalFeedImage` instances to insert a `timestamp`
    ///   - timestamp: Timestamp for cache insertion
    ///   - completion: A callback to be invoked after completion
    func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    )
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed
    /// - Parameter completion: A callback to be invoked after completion
    func retreive(completion: @escaping RetreiveCompletion)
}


