//
//  FeedImageDataLoaderCachingDecoratorTests.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 02/01/25.
//


import XCTest
import EssentialFeed

private final class FeedImageDataLoaderCachingDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    private class Task: EssentialFeed.FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any EssentialFeed.FeedImageDataLoaderTask {
        return Task()
    }
}

final class FeedImageDataLoaderCachingDecoratorTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let loader = FeedImageDataLoaderSpy()
        _ = FeedImageDataLoaderCachingDecorator(decoratee: loader)
        
        XCTAssertTrue(loader.loadedURLs.isEmpty)
    }
}
