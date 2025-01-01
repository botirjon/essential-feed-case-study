//
//  FeedCaching.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 02/01/25.
//

public protocol FeedCaching {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
