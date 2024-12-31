//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 31/12/24.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(
        _ data: Data,
        for url: URL,
        completion: @escaping FeedImageDataStore.InsertionCompletion
    ) {
        
    }
    
    public func retreive(
        dataForURL url: URL,
        completion: @escaping FeedImageDataStore.RetreiveCompletion
    ) {
        completion(.success(.none))
    }
}
