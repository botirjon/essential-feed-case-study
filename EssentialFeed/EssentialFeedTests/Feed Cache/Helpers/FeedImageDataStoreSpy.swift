//
//  FeedImageDataStoreSpy.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 31/12/24.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    
    enum Message: Equatable {
        case retreive(dataFor: URL)
        case insert(_ data: Data, url: URL)
    }
    
    private(set) var receivedMessages = [Message]()
    private var retreiveCompletions = [RetreiveCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    
    
    func insert(
        _ data: Data,
        for url: URL,
        completion: @escaping InsertionCompletion
    ) {
        receivedMessages.append(.insert(data, url: url))
        insertionCompletions.append(completion)
    }
    
    func retreive(
        dataForURL url: URL,
        completion: @escaping RetreiveCompletion
    ) {
        receivedMessages.append(.retreive(dataFor: url))
        retreiveCompletions.append(completion)
    }
    
    func completeRetreival(with error: NSError, at index: Int = 0) {
        retreiveCompletions[index](.failure(error))
    }
    
    func completeRetreival(with data: Data?, at index: Int = 0) {
        retreiveCompletions[index](.success(data))
    }
    
    func completeInsertion(with error: NSError, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionWithSuccess(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
