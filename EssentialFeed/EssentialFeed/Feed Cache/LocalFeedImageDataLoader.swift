//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 31/12/24.
//

import Foundation

public final class LocalFeedImageDataLoader {
    let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader {
    
    public typealias SaveResult = Swift.Result<Void, Error>
    
    public enum SaveError: Swift.Error {
        case failed
    }
    
    public func save(
        _ data: Data,
        for url: URL,
        completion: @escaping (SaveResult) -> Void
    ) {
        store.insert(data, for: url) { result in
            completion(result.mapError({ _ in
                SaveError.failed
            }).map({ _ in
                ()
            }))
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    private final class LoadImageDataTask: FeedImageDataLoaderTask {
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
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        store.retreive(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result.mapError({ _ in
                LoadError.failed
            }).flatMap({ data in
                return data.map { .success($0) } ?? .failure(LoadError.notFound)
            }))
        }
        return task
    }
}
