//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 29/12/24.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(
        from url: URL,
        completion: @escaping (Result) -> Void
    ) {
        client.get(from: url) { result in
            switch result {
                case .success: break
                    
                case let .failure(error):
                    completion(.failure(error))
            }
        }
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
        toCompleteWith expectedResult: RemoteFeedImageDataLoader.Result,
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
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var completions = [(HTTPClient.Result) -> Void]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
            completions.append(completion)
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}
