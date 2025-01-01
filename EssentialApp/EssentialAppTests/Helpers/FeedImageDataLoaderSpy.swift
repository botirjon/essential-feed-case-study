//
//  FeedImageDataLoaderSpy.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 02/01/25.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    
    private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    var loadedURLs: [URL] {
        messages.map { $0.url }
    }
    
    private(set) var cancelledURLs = [URL]()
    
    private class Task: FeedImageDataLoaderTask {
        
        let callback: () -> Void
        
        init(callback: @escaping () -> Void) {
            self.callback = callback
        }
        
        func cancel() {
            callback()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any EssentialFeed.FeedImageDataLoaderTask {
        messages.append((url, completion))
        return Task { [weak self] in self?.cancelledURLs.append(url) }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
    }
