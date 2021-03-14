//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Fernando Cardenas on 06.03.21.
//

import Foundation

public enum RetrievalSuccess {
    case empty, found([LocalFeedImage], Date)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) ->  Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    typealias RetrievalResult = Result<RetrievalSuccess, Error>
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping (Error?) -> Void)
    
    func retrieve(completion: @escaping RetrievalCompletion)
}
