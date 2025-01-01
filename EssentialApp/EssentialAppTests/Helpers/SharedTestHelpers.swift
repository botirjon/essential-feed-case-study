//
//  SharedTestHelpers.swift
//  EssentialApp
//
//  Created by Botirjon Nasridinov on 01/01/25.
//

import Foundation

func anyData() -> Data {
    return Data("any data".utf8)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
    }
