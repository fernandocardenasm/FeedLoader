//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fernando Cardenas on 04.03.21.
//

import EssentialFeed
import XCTest

class CacheFeedUseCaseTests: XCTestCase {
    
    class FeedStore {
        
        typealias DeletionCompletion = (Error?) -> Void
        typealias InsertionCompletion = () ->  Void
        
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert([FeedItem], Date)
        }
        
        var deleteCompletions = [DeletionCompletion]()
        var receivedMessages = [ReceivedMessage]()
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deleteCompletions.append(completion)
            receivedMessages.append(.deleteCachedFeed)
        }
        
        func insert(_ items: [FeedItem], timestamp: Date) {
            receivedMessages.append(.insert(items, timestamp))
        }
        
        func complete(withError error: Error, at index: Int = 0) {
            deleteCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deleteCompletions[index](nil)
        }
    }
    
    class LocalFeedLoader {
        private let store: FeedStore
        private let currentDate: () -> Date
        
        init(store: FeedStore, currentDate: @escaping () -> Date) {
            self.store = store
            self.currentDate = currentDate
        }
        
        func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
            store.deleteCachedFeed { error in
                if let error = error {
                    completion(error)
                } else {
                    self.store.insert(items, timestamp: self.currentDate())
                }
            }
        }
    }
    
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages.count, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save([uniqueItem(), uniqueItem()]) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        
        sut.save([uniqueItem()]) { _ in }
        
        let deletionError = anyNSError()
        store.complete(withError: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp } )

        let item = uniqueItem()
        sut.save([item]) { _ in }
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert([item], timestamp)])
    }
    
    func test_save_failsDeletionError() {
        let (sut, store) = makeSUT()
        
        let exp = expectation(description: "Wait for save to complete")
        
        var receivedError: Error?
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        let deletionError = anyNSError()
        store.complete(withError: deletionError)
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate )
        
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(
            id: UUID(),
            description: "some description",
            location: "some location",
            imageURL: URL(string: "https://some-url.com")!
        )
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any", code: 200)
    }
}
