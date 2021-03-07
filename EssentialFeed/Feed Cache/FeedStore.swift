//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Fernando Cardenas on 06.03.21.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) ->  Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping (Error?) -> Void)
}


public struct LocalFeedImage {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
