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
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any EssentialFeed.FeedImageDataLoaderTask {
        let task = decoratee.loadImageData(from: url) { _ in }
        return task
    }
}

final class FeedImageDataLoaderCachingDecoratorTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let loader = FeedImageDataLoaderSpy()
        _ = FeedImageDataLoaderCachingDecorator(decoratee: loader)
        
        XCTAssertTrue(loader.loadedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromURL() {
        let url = anyURL()
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCachingDecorator(decoratee: loader)
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [url])
    }
    
    func test_cancelImageDataLoad_cancelsTask() {
        let url = anyURL()
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCachingDecorator(decoratee: loader)
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url])
    }
}
