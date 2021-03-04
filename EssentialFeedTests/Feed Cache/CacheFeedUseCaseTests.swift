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
        var deleteCachedFeedCompletions = [(Error?) -> Void]()
        var insertCallCount = 0
        
        func deleteCachedFeed(completion: @escaping (Error?) -> Void) {
            deleteCachedFeedCompletions.append(completion)
        }
        
        func insert(_ items: [FeedItem]) {
            insertCallCount += 1
        }
        
        func complete(withError error: Error, at index: Int = 0) {
            deleteCachedFeedCompletions[index](error)
        }
    }
    
    class LocalFeedLoader {
        private let store: FeedStore
        
        
        init(store: FeedStore) {
            self.store = store
        }
        
        func save(_ items: [FeedItem]) {
            store.deleteCachedFeed { error in
                if let _ = error {
                } else {
                    self.store.insert(items)
                }
            }
        }
    }
    
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCompletions.count, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save([uniqueItem(), uniqueItem()])
        
        XCTAssertEqual(store.deleteCachedFeedCompletions.count, 1)
    }
    
    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        
        sut.save([uniqueItem()])
        
        let deletionError = anyError()
        store.complete(withError: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    private func makeSUT() -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
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
    
    private func anyError() -> Error {
        NSError(domain: "any", code: 200)
    }
}
