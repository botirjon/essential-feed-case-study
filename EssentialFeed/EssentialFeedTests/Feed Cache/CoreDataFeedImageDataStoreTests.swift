//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 31/12/24.
//

import XCTest
import EssentialFeed



final class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteWith: notFound())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        
        let url = URL(string: "https://a-url.com")!
        let nonMatchingURL = URL(string: "https://a-non-matching-url.com")!
        
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toCompleteWith: notFound(), for: nonMatchingURL)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
        let sut = makeSUT()
        
        let matchingURL = URL(string: "https://a-url.com")!
        
        let data = anyData()
        
        insert(data, for: matchingURL, into: sut)
        
        expect(sut, toCompleteWith: found(data), for: matchingURL)
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = makeSUT()
        
        let matchingURL = URL(string: "https://a-url.com")!
        
        let firstStoredData = Data("first-data".utf8)
        let latestStoredData = Data("latest-data".utf8)
        
        insert(firstStoredData, for: matchingURL, into: sut)
        insert(latestStoredData, for: matchingURL, into: sut)
        
        expect(sut, toCompleteWith: found(latestStoredData), for: matchingURL)
    }
    
    func test_sideEffects_runSerially() {
        let sut = makeSUT()
        let url = anyURL()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert([localImage(url: url)], timestamp: Date()) { _ in
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.insert(anyData(), for: url) { _ in    op2.fulfill() }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(anyData(), for: url) { _ in op3.fulfill() }
        
        wait(for: [op1, op2, op3], timeout: 5.0, enforceOrder: true)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteWith expectedResult: FeedImageDataStore.RetreivalResult, for url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for retreive completion")
        
        sut.retreive(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedData), .success(expectedData)):
                    
                    XCTAssertEqual(
                        receivedData,
                        expectedData,
                        file: file,
                        line: line
                    )
                    
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
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache insertion")
        let image = localImage(url: url)
        sut.insert([image], timestamp: Date()) { result in
            switch result {
                case let .failure(error):
                    XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                    
                    exp.fulfill()
                    
                case .success:
                    sut.insert(data, for: url) { result in
                        if case let Result.failure(error) = result {
                            XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                        }
                        exp.fulfill()
                    }
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func notFound() -> FeedImageDataStore.RetreivalResult {
        return .success(.none)
    }
    
    private func found(_ data: Data) -> FeedImageDataStore.RetreivalResult {
        return .success(data)
    }
    
    private func localImage(url: URL, data: Data? = nil) -> LocalFeedImage {
        return LocalFeedImage(
            id: UUID(),
            description: "any",
            location: "any",
            url: url
        )
    }
}
