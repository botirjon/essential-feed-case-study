//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 30/12/24.
//

import XCTest

private final class LocalFeedImageDataLoader {
    
    init(store: Any) {}
}

final class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (
        sut: LocalFeedImageDataLoader,
        store: FeedImageDataStoreSpy
    ) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }
    
    private class FeedImageDataStoreSpy {
        var receivedMessages = [Any]()
    }
}
