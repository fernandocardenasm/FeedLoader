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
    private let calendar = Calendar(identifier: .gregorian)
    
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
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(.found(feed, timestamp)) where self.validate(timestamp):
                completion(.success(feed.toModels()))
            case .success(.empty):
                completion(.success([]))
            case .success(.found):
                self.store.deleteCachedFeed { _ in }
                completion(.success([]))
            case .failure(let error):
                self.store.deleteCachedFeed { _ in }
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
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: Constants.maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
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

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map { FeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url) }
    }
}

