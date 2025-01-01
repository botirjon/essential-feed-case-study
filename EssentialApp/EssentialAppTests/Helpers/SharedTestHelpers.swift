//
//  SharedTestHelpers.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 01/01/25.
//

import Foundation
import EssentialFeed

func anyData() -> Data {
    return Data("any data".utf8)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: "a description", location: "a location", url: URL(string: "https://any-url.com")!)]
    }
