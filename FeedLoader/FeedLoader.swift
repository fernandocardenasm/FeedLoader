//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by Fernando Cardenas on 14.02.21.
//

import Foundation

protocol FeedLoader {
    func load(completion: @escaping (Result<[FeedItem], Error>) -> Void)
}
