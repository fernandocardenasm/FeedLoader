//
//  XCTestCase+MemoryLeaksTracking.swift
//  FeedLoaderTests
//
//  Created by Fernando Cardenas on 26.02.21.
//

import XCTest

extension XCTestCase {
    public func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential Memory leak.", file: file, line: line)
        }
    }
}
