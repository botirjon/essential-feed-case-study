//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 12/12/24.
//

import Foundation

internal final class FeedCachePolicy {
    static private let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
    
    private init() {}
    
    static private var maxCacheAgeInDays: Int { 7 }
    
    internal static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
