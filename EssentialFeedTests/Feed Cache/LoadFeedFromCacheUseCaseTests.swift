//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Fernando Cardenas on 07.03.21.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
    }
    
    func test_load_failsOnRetrievalError() {
        
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        
    }
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        
    }
    
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
}
