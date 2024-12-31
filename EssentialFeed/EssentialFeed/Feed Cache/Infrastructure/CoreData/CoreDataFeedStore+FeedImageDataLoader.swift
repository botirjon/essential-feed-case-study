//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 31/12/24.
//

import Foundation
import CoreData

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(
        _ data: Data,
        for url: URL,
        completion: @escaping FeedImageDataStore.InsertionCompletion
    ) {
        perform { context in
            completion(Result {
                try ManagedFeedImage
                    .first(with: url, in: context)
                    .map({ $0.data = data }).map(context.save)
            })
        }
    }
    
    public func retreive(
        dataForURL url: URL,
        completion: @escaping FeedImageDataStore.RetreiveCompletion
    ) {
        perform { context in
            completion(Result(catching: {
                try ManagedFeedImage.first(with: url, in: context)?.data
            }))
        }
    }
}
