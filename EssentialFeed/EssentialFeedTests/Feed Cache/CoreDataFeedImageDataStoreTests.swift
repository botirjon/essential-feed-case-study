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
    
    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
        let sut = makeSUT()
        
        let url = URL(string: "https://a-url.com")!
        let nonMatchingURL = URL(string: "https://a-non-matching-url.com")!
        
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toCompleteWith: notFound(), for: nonMatchingURL)
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
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache insertion")
        let image = localImage(url: url)
        sut.insert([image], timestamp: Date()) { result in
            switch result {
                case let .failure(error):
                    XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                    
                case .success:
                    sut.insert(data, for: url) { result in
                        if case let Result.failure(error) = result {
                            XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                        }
                    }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func notFound() -> FeedImageDataStore.RetreivalResult {
        return .success(.none)
    }
    
    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
}