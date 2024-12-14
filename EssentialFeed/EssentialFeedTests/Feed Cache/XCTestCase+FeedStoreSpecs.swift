//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Botirjon Nasridinov on 14/12/24.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetreiveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetreiveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    @discardableResult
    func insert(
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
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for deletion completion")
        
        var deletionError: Error?
        sut.deleteCachedFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
}
