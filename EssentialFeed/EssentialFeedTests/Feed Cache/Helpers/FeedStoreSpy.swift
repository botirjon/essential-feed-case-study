//
//  FeedStoreSpy.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 11/12/24.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retreive
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [InsertionCompletion]()
    var retreiveCompletions = [RetreiveCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    ) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func retreive(completion: @escaping RetreiveCompletion) {
        retreiveCompletions.append(completion)
        receivedMessages.append(.retreive)
    }
    
    func completeRetreival(with error: Error, at index: Int = 0) {
        retreiveCompletions[index](.failure(error))
    }

    func completeRetreivalWithEmptyCache(at index: Int = 0) {
        retreiveCompletions[index](.success(nil))
    }
    
    func completeRetreival(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retreiveCompletions[index](
            .success(CachedFeed(feed: feed, timestamp: timestamp))
        )
    }
}
