//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 29/12/24.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    private struct HTTPTaskWrapper: FeedImageDataLoaderTask {
        let wrapped: HTTPClientTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    @discardableResult
    func loadImageData(
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> FeedImageDataLoaderTask {
        let task = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
                case let .success((data, response)):
                    if response.statusCode == 200 && !data.isEmpty {
                        completion(.success(data))
                    } else {
                        completion(.failure(Error.invalidData))
                    }
                    
                case let .failure(error):
                    completion(.failure(error))
            }
        }
        
        return HTTPTaskWrapper(wrapped: task)
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url1 = URL(string: "https://a-url.com")!
        let url2 = URL(string: "https://another-url.com")!
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url1) { _ in }
        sut.loadImageData(from: url2) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url1, url2])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let expectedError = anyNSError()
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(expectedError)) {
            client.complete(with: expectedError)
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        expect(
            sut,
            toCompleteWith: failure(.invalidData)
        ) {
            client.complete(withStatusCode: 400, data: self.anyData())
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }
    
    func test_loadImageDataFromURL_deliversNonEmptyDataOn200HTTPResponse() {
        let (sut, loader) = makeSUT()
        let nonEmptyData = Data("non-empty-data".utf8)
        
        expect(sut, toCompleteWith: .success(nonEmptyData)) {
            loader.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var capturedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL(), completion: { result in
            capturedResults.append(result)
        })
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(
        _ sut: RemoteFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: @escaping () -> Void,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let url = anyURL()
        
        let exp = expectation(description: "Wait for completion")

        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedData), .success(expectedData)):
                    XCTAssertEqual(
                        receivedData,
                        expectedData,
                        file: file,
                        line: line
                    )
                    
                    
                case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                    
                    XCTAssertEqual(
                        receivedError,
                        expectedError,
                        file: file,
                        line: line
                    )
                    
                case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                    
                    XCTAssertEqual(
                        receivedError,
                        expectedError,
                        file: file,
                        line: line
                    )
                    
                default:
                    XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private struct Task: HTTPClientTask {
            func cancel() {
                
            }
        }
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        private(set) var cancelledURLs = [URL]()
        
        var requestedURLs: [URL] { messages.map { $0.url } }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task()
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, response)))
        }
    }
}
