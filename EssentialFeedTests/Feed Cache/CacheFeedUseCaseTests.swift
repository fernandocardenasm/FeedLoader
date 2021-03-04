//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fernando Cardenas on 04.03.21.
//

import XCTest

class CacheFeedUseCaseTests: XCTestCase {
    
    class FeedStore {
        var deleteCachedFeedCallCount = 0
    }
    
    class LocalFeedLoader {
        init(store: FeedStore) {
            
        }
    }
    
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
