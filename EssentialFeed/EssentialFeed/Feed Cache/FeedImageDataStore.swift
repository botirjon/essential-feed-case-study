//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 31/12/24.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    typealias RetreiveCompletion = (Result) -> Void
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    func insert(_ data: Data, for url: URL, completion: @escaping InsertionCompletion)
    func retreive(dataForURL url: URL, completion: @escaping RetreiveCompletion)
}
