//
//  FeedImageDataLoaderCachingDecoratorTests.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 02/01/25.
//


import XCTest
import EssentialFeed
import EssentialApp

final class FeedImageDataLoaderCachingDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    
    func test_init_doesNotLoadImageData() {
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromURL() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [url])
    }
    
    func test_cancelImageDataLoad_cancelsTask() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url])
    }
    
    func test_loadImageData_deliversImageDataOnLoaderSuccess() {
        let imageData = anyData()
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(imageData)) {
            loader.complete(with: imageData)
        }
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            loader.complete(with: anyNSError())
        }
    }
    
    func test_loadImageData_cachesLoadedImageDataOnLoaderSuccess() {
        let url = anyURL()
        let imageData = anyData()
        let cache = FeedImageDataCacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: url) { _ in }
        
        loader.complete(with: imageData)
        
        XCTAssertEqual(cache.messages, [.save(imageData, url: url)])
    }
    
    func test_loadImageData_doesNotCacheOnLoaderFailure() {
        let cache = FeedImageDataCacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: anyURL()) { _ in }
        
        loader.complete(with: anyNSError())
        
        XCTAssertTrue(cache.messages.isEmpty)
    }
    
//    func test_cancelImageDataLoad_doesNotCache() {
//        let cache = FeedImageDataCacheSpy()
//        let (sut, loader) = makeSUT(cache: cache)
//        
//        let task = sut.loadImageData(from: anyURL()) { _ in }
//        
//        task.cancel()
//        loader.complete(with: anyData())
//        
//        XCTAssertTrue(cache.messages.isEmpty)
//    }
    
    // MARK: - Helpers
    
    private func makeSUT(cache: FeedImageDataCacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCachingDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private class FeedImageDataCacheSpy: FeedImageDataCaching {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save(_ data: Data, url: URL)
        }
        
        func save(
            _ data: Data,
            for url: URL,
            completion: @escaping (FeedImageDataCaching.Result) -> Void
        ) {
            messages.append(.save(data, url: url))
        }
    }
}
