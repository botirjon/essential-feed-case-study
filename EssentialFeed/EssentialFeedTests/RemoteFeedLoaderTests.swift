//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Botirjon Nasridinov on 02/12/24.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        let _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let client = HTTPClient()
        let loader = RemoteFeedLoader()
        
        loader.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
