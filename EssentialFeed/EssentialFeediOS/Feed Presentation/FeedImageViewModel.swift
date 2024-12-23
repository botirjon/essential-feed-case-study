//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 22/12/24.
//

import UIKit
import EssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
