//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 13/12/24.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }
    
    private let storeURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!.appendingPathComponent("image-feed.store")
    
    func retreive(completion: @escaping FeedStore.RetreiveCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    }
    
    func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping FeedStore.InsertionCompletion
    ) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feed, timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let storeURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent("image-feed.store")
        
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent("image-feed.store")
        
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retreive_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for retreive completion")
        
        sut.retreive { result in
            switch result {
                case .empty:
                    break
                    
                default:
                    XCTFail("Expected empty result, got \(result) insted")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retreive_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for retreive completion")
        sut.retreive { firstResult in
            sut.retreive { secondResult in
                switch (firstResult, secondResult) {
                    case (.empty, .empty):
                        break
                        
                    default:
                        XCTFail(
                            "Expected retrieving twice from empty cache to deliver the same empty result, got \(firstResult) and \(secondResult) instead"
                        )
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retreiveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableFeedStore()
        let feed = uniqueImageFeed().local
        let timestamp = Date.init()
        let exp = expectation(description: "Wait for retreive completion")
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            
            sut.retreive { retrievedResult in
                switch retrievedResult {
                    case let .found(retrievedFeed, retrievedTimestamp):
                        XCTAssertEqual(retrievedFeed, feed)
                        XCTAssertEqual(retrievedTimestamp, timestamp)
                        
                    default:
                        XCTFail(
                            "Expected found result with \(feed), got \(retrievedResult) instead"
                        )
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
