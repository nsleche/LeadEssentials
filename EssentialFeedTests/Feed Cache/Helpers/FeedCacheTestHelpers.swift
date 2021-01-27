//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Antonio Alves on 1/3/21.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    return FeedImage(feedId: UUID(), description: "any description", location: "any location", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(feedId: $0.feedId, description: $0.description, location: $0.location, url: $0.url) }
    return (models, local)
}

// @learn: this is a DSL
extension Date {
    
    func minusFeedCacheMaxAge() -> Date {
        return self.adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {

    func adding(seconds: Double) -> Date {
        return self + seconds
    }
}
