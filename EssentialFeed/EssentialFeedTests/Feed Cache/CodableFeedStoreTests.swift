//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 13/12/24.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retreive(completion: @escaping FeedStore.RetreiveCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
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
}
