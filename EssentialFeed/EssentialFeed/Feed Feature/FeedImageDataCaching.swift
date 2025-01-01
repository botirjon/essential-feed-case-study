//
//  FeedImageDataCaching.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 02/01/25.
//

import Foundation

public protocol FeedImageDataCaching {
    typealias Result = Swift.Result<Void, Error>
    
    func save(
        _ data: Data,
        for url: URL,
        completion: @escaping (Result) -> Void
    )
}
