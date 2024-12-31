//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 31/12/24.
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore: @retroactive FeedImageDataStore {
    public func insert(
        _ data: Data,
        for url: URL,
        completion: @escaping FeedImageDataStore.InsertionCompletion
    ) {
        
    }

    public func retreive(
        dataForURL url: URL,
        completion: @escaping FeedImageDataStore.RetreiveCompletion
    ) {
        completion(.success(.none))
    }

    
}

final class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteWith: notFound())
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteWith expectedResult: FeedImageDataStore.RetreivalResult, for url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for retreive completion")
        
        sut.retreive(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedData), .success(expectedData)):
                    
                    XCTAssertEqual(receivedData, expectedData)
                    
                default:
                    XCTFail(
                        "Expected \(expectedResult), got \(receivedResult) instead",
                        file: file,
                        line: line
                    )
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func notFound() -> FeedImageDataStore.RetreivalResult {
        return .success(.none)
    }
}
