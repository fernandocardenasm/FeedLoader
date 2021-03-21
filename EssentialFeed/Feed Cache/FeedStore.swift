//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Fernando Cardenas on 06.03.21.
//

import Foundation

public struct CachedFeed: Equatable {
    public let feed: [LocalFeedImage]
    public let timestamp: Date
    
    public init(feed: [LocalFeedImage], timestamp: Date) {
        self.feed = feed
        self.timestamp = timestamp
    }
}

public protocol FeedStore {
    typealias DeletionCompletion = (Result<Void, Error>) -> Void
    typealias InsertionCompletion = (Result<Void, Error>) ->  Void
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    func retrieve(completion: @escaping RetrievalCompletion)
}
