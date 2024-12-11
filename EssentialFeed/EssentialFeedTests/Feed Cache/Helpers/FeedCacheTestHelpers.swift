//
//  FeedCacheTestHelpers.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 11/12/24.
//

import Foundation
import EssentialFeed

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let feed = [uniqueImage(), uniqueImage()]
    let localItems = feed.map {
        LocalFeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url
        )
    }
    return (feed, localItems)
}

func uniqueImage() -> FeedImage {
    return FeedImage(
        id: UUID(),
        description: "any",
        location: "any",
        url: anyURL()
    )
}

extension Date {
    func adding(days: Int) -> Date {
        return Calendar.init(identifier: Calendar.Identifier.gregorian).date(
            byAdding: .day,
            value: days,
            to: self
        )!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
