//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Botirjon Nasridinov on 02/12/24.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
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
