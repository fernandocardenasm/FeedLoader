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
        
        var deleteCompletions = [DeletionCompletion]()
        var insertions = [(items: [FeedItem], timestamp: Date)]()
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deleteCompletions.append(completion)
        }
        
        func insert(_ items: [FeedItem], timestamps: Date) {
            insertions.append((items, timestamps))
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
        
        func save(_ items: [FeedItem]) {
            store.deleteCachedFeed { error in
                if let _ = error {
                } else {
                    self.store.insert(items, timestamps: self.currentDate())
                }
            }
        }
    }
    
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCompletions.count, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save([uniqueItem(), uniqueItem()])
        
        XCTAssertEqual(store.deleteCompletions.count, 1)
    }
    
    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        
        sut.save([uniqueItem()])
        
        let deletionError = anyError()
        store.complete(withError: deletionError)
        
        XCTAssertEqual(store.insertions.count, 0)
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp } )

        let item = uniqueItem()
        sut.save([item])
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, [item])
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
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
    
    private func anyError() -> Error {
        NSError(domain: "any", code: 200)
    }
}
