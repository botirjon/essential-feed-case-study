//
//  FeedLoaderCachingDecoratorTests.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 02/01/25.
//

import XCTest
import EssentialFeed

protocol FeedCaching {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}

private final class FeedLoaderCachingDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCaching
    
    init(decoratee: FeedLoader, cache: FeedCaching) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            if let feed = try? result.get() {
                self?.cache.save(feed) { _ in }
            }
            completion(result)
        }
    }
}

final class FeedLoaderCachingDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed)])
    }
    
    func test_load_doesNotCacheOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)
        sut.load { _ in }
        
        XCTAssertTrue(cache.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> FeedLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCachingDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class CacheSpy: FeedCaching {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(_ feed: [FeedImage], completion: @escaping (FeedCaching.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}
