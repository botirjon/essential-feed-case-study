//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Botirjon Nasridinov on 14/12/24.
//

import Foundation
import CoreData

class CoreDataFeedStore: FeedStore {
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    func insert(
        _ feed: [EssentialFeed.LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    ) {
        
    }
    
    func retreive(completion: @escaping RetreiveCompletion) {
        completion(.empty)
    }
    
    
}


class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
