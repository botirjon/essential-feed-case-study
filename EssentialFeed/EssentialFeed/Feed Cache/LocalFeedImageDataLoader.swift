//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 31/12/24.
//

import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
    
    private final class Task: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    public func save(_ data: Data, for url: URL) {
        store.insert(data, for: url) { _ in }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        let task = Task(completion)
        store.retreive(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result.mapError({ _ in
                Error.failed
            }).flatMap({ data in
                return data.map { .success($0) } ?? .failure(Error.notFound)
            }))
        }
        return task
    }
}
