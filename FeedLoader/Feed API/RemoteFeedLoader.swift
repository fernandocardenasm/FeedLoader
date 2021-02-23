//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by Fernando Cardenas on 15.02.21.
//

import Foundation

public typealias FeedLoaderResult = Result<[FeedItem], Error>

public protocol FeedLoader {
    func load(completion: @escaping (FeedLoaderResult) -> Void)
}

final public class RemoteFeedLoader: FeedLoader {
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    let url: URL
    let client: HTTPClient
    
    public typealias Result = FeedLoaderResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(url: url) { [weak self] result in
            guard let _ = self else { return }
            
            switch result {
            case let .success((data, response)):
                completion(FeedItemsMapper.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

private struct FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] {
            items.map { $0.item }
        }
    }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}
