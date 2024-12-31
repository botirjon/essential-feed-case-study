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
    
    private final class Task: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        let task = Task(completion)
        store.retreive(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result.mapError({ _ in
                Error.failed
            }).flatMap({ data in
                return data.map { .success($0) } ?? .failure(Error.notFound)
            }))
        }
        return task
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
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound()) {
            store.completeRetreival(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_deliversStoredDataWhenStoreFindsImageDataForURL() {
        let (sut, store) = makeSUT()
        
        let imageData = anyData()
        
        expect(sut, toCompleteWith: .success(imageData)) {
            store.completeRetreival(with: imageData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()
        
        store.completeRetreival(with: foundData)
        store.completeRetreival(with: .none)
        store.completeRetreival(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var received = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL(), completion: {
            received.append($0)
        })
        
        sut = nil
        
        store.completeRetreival(with: anyData())
        
        XCTAssertTrue(received.isEmpty)
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
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.notFound)
    }
    
    private class FeedImageDataStoreSpy: FeedImageDataStore {
        
        enum Message: Equatable {
            case retreive(dataFor: URL)
        }
        
        private(set) var receivedMessages = [Message]()
        private var retreiveCompletions = [RetreiveCompletion]()
        
        
        func retreive(
            dataForURL url: URL,
            completion: @escaping RetreiveCompletion
        ) {
            receivedMessages.append(.retreive(dataFor: url))
            retreiveCompletions.append(completion)
        }
        
        func completeRetreival(with error: NSError, at index: Int = 0) {
            retreiveCompletions[index](.failure(error))
        }
        
        func completeRetreival(with data: Data?, at index: Int = 0) {
            retreiveCompletions[index](.success(data))
        }
    }
}
