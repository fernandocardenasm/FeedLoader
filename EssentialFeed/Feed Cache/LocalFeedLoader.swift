//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Fernando Cardenas on 06.03.21.
//

import Foundation

public class LocalFeedLoader {
    
    private struct Constants {
        static let maxCacheAgeInDays = 7
    }
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = Result<[FeedImage], Error>
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ images: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(images: images, withCompletion: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { result in
            switch result {
            case .success(.empty):
                break
            case .success(.found):
                break
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(images: [FeedImage], withCompletion completion: @escaping (SaveResult) -> Void) {
        store.insert(images.toModels(), timestamp: currentDate()) { [weak self] error in
            guard let _ = self else { return }
            
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    func toModels() -> [LocalFeedImage] {
        map { LocalFeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url) }
    }
}
