//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 31/12/24.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    typealias RetreiveCompletion = (Result) -> Void
    
    func retreive(dataForURL url: URL, completion: @escaping RetreiveCompletion)
}
