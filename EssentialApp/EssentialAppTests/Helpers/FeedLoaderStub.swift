//
//  FeedLoaderStub.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 02/01/25.
//

import EssentialFeed

class FeedLoaderStub: FeedLoader {
    
    let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
