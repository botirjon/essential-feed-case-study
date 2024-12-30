//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 30/12/24.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    
    typealias Result = Swift.Result<Data?, Error>
    typealias RetreiveCompletion = (Result) -> Void
    
    func retreive(dataForURL url: URL, completion: @escaping RetreiveCompletion)
}

private final class LocalFeedImageDataLoader: FeedImageDataLoader {
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    
    let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    enum Error: Swift.Error {
        case failed
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        store.retreive(dataForURL: url) { _ in
            completion(.failure(Error.failed))
        }
        return Task()
    }
}

final class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retreive(dataFor: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed()) {
            let retreivalError = anyNSError()
            store.completeRetreival(with: retreivalError)
        }
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
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: @escaping () -> Void,
        file: StaticString
        = #filePath, line: UInt = #line
    ) {
        let url = anyURL()
        
        let exp = expectation(description: "Wait for completion")
        
      _ = sut.loadImageData(from: url) { (receivedResult) in
            switch (receivedResult, expectedResult) {
                case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                    
                case let (
                    .failure(receivedError as LocalFeedImageDataLoader.Error),
                    .failure(expectedError as LocalFeedImageDataLoader.Error)
                ):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                    
                case let (.success(receivedData), .success(expectedData)):
                    XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                    
                default:
                    XCTFail("Expected \(expectedResult), got \(receivedResult) instead!", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.failed)
    }
    
    private class FeedImageDataStoreSpy: FeedImageDataStore {
        
        enum Message: Equatable {
            case retreive(dataFor: URL)
        }
        
        private(set) var receivedMessages = [Message]()
        private var retereiveCompletions = [RetreiveCompletion]()
        
        
        func retreive(
            dataForURL url: URL,
            completion: @escaping RetreiveCompletion
        ) {
            receivedMessages.append(.retreive(dataFor: url))
            retereiveCompletions.append(completion)
        }
        
        func completeRetreival(with error: NSError, at index: Int = 0) {
            retereiveCompletions[index](.failure(error))
        }
    }
}
