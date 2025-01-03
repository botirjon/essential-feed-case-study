//
//  InMemoryFeedStore.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 03/01/25.
//

import Foundation
import EssentialFeed

class InMemoryFeedStore: FeedStore, FeedImageDataStore {
    private(set) var feedCache: CachedFeed?
    private(set) var feedImageDataCache = [URL: Data]()
    
    static var empty: InMemoryFeedStore { InMemoryFeedStore() }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        let store = InMemoryFeedStore()
        store.feedCache = CachedFeed(feed: [], timestamp: .distantPast)
        return store
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
        let store = InMemoryFeedStore()
        store.feedCache = CachedFeed(feed: [], timestamp: Date())
        return store
    }
    
    func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        feedCache = nil
        completion(.success(()))
    }
    
    func insert(
        _ feed: [EssentialFeed.LocalFeedImage],
        timestamp: Date,
        completion: @escaping FeedStore.InsertionCompletion
    ) {
        feedCache = CachedFeed(feed: feed, timestamp: timestamp)
        completion(.success(()))
    }
    
    func retreive(completion: @escaping FeedStore.RetreiveCompletion) {
        completion(.success(feedCache))
    }
    
    func insert(
        _ data: Data,
        for url: URL,
        completion: @escaping FeedImageDataStore.InsertionCompletion
    ) {
        feedImageDataCache[url] = data
    }
    
    func retreive(
        dataForURL url: URL,
        completion: @escaping FeedImageDataStore.RetreiveCompletion
    ) {
        completion(.success(feedImageDataCache[url]))
    }
    }
