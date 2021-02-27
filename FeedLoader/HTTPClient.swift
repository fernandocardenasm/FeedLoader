//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by Fernando Cardenas on 14.02.21.
//

import Foundation

public typealias HTTPClientResult = (Result<(Data, HTTPURLResponse), Error>)

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
