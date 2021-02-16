//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by Fernando Cardenas on 15.02.21.
//

import Foundation

final public class RemoteFeedLoader {
    
    let url: URL
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(url: url) { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
