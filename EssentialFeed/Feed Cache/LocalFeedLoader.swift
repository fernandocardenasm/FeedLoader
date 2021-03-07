//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Fernando Cardenas on 06.03.21.
//

import Foundation

public class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items: items, withCompletion: completion)
            }
        }
    }
    
    private func cache(items: [FeedItem], withCompletion completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toModels(), timestamp: currentDate()) { [weak self] error in
            guard let _ = self else { return }
            
            completion(error)
        }
    }
}

private extension Array where Element == FeedItem {
    func toModels() -> [LocalFeedImage] {
        map { LocalFeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.imageURL) }
    }
}
