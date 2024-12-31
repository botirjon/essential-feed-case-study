//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Botirjon Nasridinov on 11/12/24.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetreivalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache() { _ in }
        store.completeRetreival(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retreive, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache() { _ in }
        store.completeRetreivalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    func test_validateCache_doesNotDeleteCacheOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(
            seconds: 1
        )
        let (sut, store) = makeSUT()
        
        sut.validateCache() { _ in }
        store
            .completeRetreival(
                with: feed.local,
                timestamp: nonExpiredTimestamp
            )
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    func test_validateCache_deletesExpirationCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT()
        
        sut.validateCache() { _ in }
        store
            .completeRetreival(
                with: feed.local,
                timestamp: expirationTimestamp
            )
        
        XCTAssertEqual(store.receivedMessages, [.retreive, .deleteCachedFeed])
    }
    
    func test_validateCache_deletesExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(
            seconds: -1
        )
        let (sut, store) = makeSUT()
        
        sut.validateCache() { _ in }
        store
            .completeRetreival(
                with: feed.local,
                timestamp: expiredTimestamp
            )
        
        XCTAssertEqual(store.receivedMessages, [.retreive, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache() { _ in }
        
        sut = nil
        store.completeRetreival(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (
        sut: LocalFeedLoader,
        store: FeedStoreSpy
    ) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}


