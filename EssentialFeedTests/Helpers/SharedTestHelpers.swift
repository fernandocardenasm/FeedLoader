//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Fernando Cardenas on 09.03.21.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any", code: 200)
}
