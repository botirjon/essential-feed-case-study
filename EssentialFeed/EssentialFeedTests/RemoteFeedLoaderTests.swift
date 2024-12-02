//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Botirjon Nasridinov on 02/12/24.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    
    static var shared = HTTPClient()
    
    func get(from url: URL) {}
}
 
class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    override func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let client = HTTPClient.shared
        let loader = RemoteFeedLoader()
        
        loader.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
