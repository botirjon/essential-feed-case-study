//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 03/01/25.
//

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(_ message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
