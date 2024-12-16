//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 08/12/24.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
