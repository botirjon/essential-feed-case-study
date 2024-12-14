//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 13/12/24.
//

import XCTest
import EssentialFeed



class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retreive_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retreive_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retreive_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date.init()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retreive_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date.init()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(
            to: storeURL,
            atomically: false,
            encoding: .utf8
        )
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(
            to: storeURL,
            atomically: false,
            encoding: .utf8
        )
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        // Given
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert(
            (latestFeed, latestTimestamp),
            to: sut
        )
        
        XCTAssertNil(latestInsertionError,  "Expected to insert successfully")
        expect(
            sut,
            toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp)
        )
    }
    
    func test_insert_deliversFailureOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
                
        XCTAssertNotNil(insertionError)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(insertionError, "Expected to insert successfully")
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected to delete cache successfully")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletionPermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletionPermissionURL)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected to receive error, got nil instead")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetreiveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieve completion")
        
        sut.retreive { retrievedResult in
            
            switch (retrievedResult, expectedResult) {
                case (.empty, .empty), (.failure, .failure):
                    break
                    
                case let (
                    .found(retrievedFeed, retrievedTimestamp),
                    .found(expectedFeed, expectedTimestamp)
                ):
                    XCTAssertEqual(
                        retrievedFeed,
                        expectedFeed,
                        file: file,
                        line: line
                    )
                    XCTAssertEqual(
                        retrievedTimestamp,
                        expectedTimestamp,
                        file: file,
                        line: line
                    )
                    
                default:
                    XCTFail(
                        "Expected to retrieve result \(expectedResult), got \(retrievedResult) instead", file: file, line: line
                    )
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetreiveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    @discardableResult
    private func insert(
        _ cache: (
            feed: [LocalFeedImage],
            timestamp: Date
        ),
        to sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let exp = expectation(description: "Wait for insert completion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for deletion completion")
        
        var deletionError: Error?
        sut.deleteCachedFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory()
            .appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
