//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by Fernando Cardenas on 14.02.21.
//

import Foundation

public protocol HTTPClient {
    func get(url: URL, completion: @escaping (Result<HTTPURLResponse, Error>) -> Void)
}
