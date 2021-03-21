//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Fernando Cardenas on 07.03.21.
//

import EssentialFeed
import Foundation

class FeedStoreSpy: FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) ->  Void
    typealias LoadCompletion = FeedStore.RetrievalCompletion
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    var deleteCompletions = [DeletionCompletion]()
    var insertCompletions = [InsertionCompletion]()
    var loadCompletions = [LoadCompletion]()
    var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
        insertCompletions.append(completion)
        receivedMessages.append(.insert(images, timestamp))
    }
    
    func completeDeletion(withError error: Error, at index: Int = 0) {
        deleteCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deleteCompletions[index](nil)
    }
    
    func completeInsertion(withError error: Error, at index: Int = 0) {
        insertCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertCompletions[index](nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        loadCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrievalSuccessfullyEmpty(at index: Int = 0) {
        loadCompletions[index](.success(.none))
    }
    
    func completeRetrievalSuccessfullyFound(images: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        loadCompletions[index](.success(CachedFeed(feed: images, timestamp: timestamp)))
    }
    
    func completeRetrieval(withError error: Error, at index: Int = 0) {
        loadCompletions[index](.failure(error))
    }
}
