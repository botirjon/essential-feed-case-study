//
//  RemoteFeedImageLoader.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 30/12/24.
//

import Foundation

public class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            task
                .complete(
                    with: result.mapError { _ in Error.connectivity
                    }.flatMap({ (data, response) in
                        let validResponse = response.isOK && !data.isEmpty
                        return validResponse ?
                            .success(data) :
                            .failure(Error.invalidData)
                    }))
        }
        
        return task
    }
}
