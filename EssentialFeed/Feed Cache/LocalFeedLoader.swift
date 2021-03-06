//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Fernando Cardenas on 06.03.21.
//

import Foundation

private struct FeedCachePolicy {
    
    private struct Constants {
        static let maxCacheAgeInDays = 7
    }
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: Constants.maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}

public class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    public typealias SaveResult = Result<Void, Error>
    public typealias LoadResult = Result<[FeedImage], Error>
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ images: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] saveResult in
            guard let self = self else { return }
            
            switch saveResult {
            case .success:
                self.cache(images: images, withCompletion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
            case .success:
                completion(.success([]))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
            case .success:
                break
            }
        }
    }
    
    private func cache(images: [FeedImage], withCompletion completion: @escaping (SaveResult) -> Void) {
        store.insert(images.toModels(), timestamp: currentDate()) { [weak self] insertResult in
            guard let _ = self else { return }
            
            switch insertResult {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
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

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map { FeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url) }
    }
}

