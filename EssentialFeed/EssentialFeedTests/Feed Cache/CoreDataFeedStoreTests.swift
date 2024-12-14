//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Botirjon Nasridinov on 14/12/24.
//

import XCTest
import EssentialFeed

class CoreDataFeedStore: FeedStore {
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }

    func insert(
        _ feed: [EssentialFeed.LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    ) {
        
    }

    func retreive(completion: @escaping RetreiveCompletion) {
        completion(.empty)
    }

    
}


class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retreive_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retreive_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retreive_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    func test_retreive_hasNoSideEffectsOnNonEmptyCache() {
        
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        
    }

    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }

    func test_storeSideEffects_runSerially() {
        
    }

    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
