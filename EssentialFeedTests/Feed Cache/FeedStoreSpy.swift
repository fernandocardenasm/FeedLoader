//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Fernando Cardenas on 07.03.21.
//

import EssentialFeed
import Foundation

class FeedStoreSpy: FeedStore {
    
    typealias DeletionCompletion = FeedStore.DeletionCompletion
    typealias InsertionCompletion = FeedStore.InsertionCompletion
    typealias RetrievalCompletion = FeedStore.RetrievalCompletion
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private var deleteCompletions = [DeletionCompletion]()
    private var insertCompletions = [InsertionCompletion]()
    private var retrivalCompletions = [RetrievalCompletion]()
    var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping DeletionCompletion) {
        insertCompletions.append(completion)
        receivedMessages.append(.insert(images, timestamp))
    }
    
    func completeDeletion(withError error: Error, at index: Int = 0) {
        deleteCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deleteCompletions[index](.success(()))
    }
    
    func completeInsertion(withError error: Error, at index: Int = 0) {
        insertCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrivalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrievalSuccessfullyEmpty(at index: Int = 0) {
        retrivalCompletions[index](.success(.none))
    }
    
    func completeRetrievalSuccessfullyFound(images: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrivalCompletions[index](.success(CachedFeed(feed: images, timestamp: timestamp)))
    }
    
    func completeRetrieval(withError error: Error, at index: Int = 0) {
        retrivalCompletions[index](.failure(error))
    }
}
