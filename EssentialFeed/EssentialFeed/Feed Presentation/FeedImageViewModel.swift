//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 22/12/24.
//

import UIKit
import EssentialFeed

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
}
