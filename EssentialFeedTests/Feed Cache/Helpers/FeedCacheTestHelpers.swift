//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Fernando Cardenas on 09.03.21.
//

import EssentialFeed
import Foundation

func uniqueImage() -> FeedImage {
    FeedImage(
        id: UUID(),
        description: "some description",
        location: "some location",
        url: URL(string: "https://some-url.com")!
    )
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (models, local)
}

extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
