//
//  CoreDataFeedStore+FeedStore.swift
//  FeedStoreChallenge
//
//  Created by Antonio Alves on 1/18/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
	
	public func retrieve() throws -> CachedFeed? {
		
		try performSync { context in
			Result {
				try ManagedFeedCache.find(in: context).map {
					CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
				}
			}
		}
	}
	
	public func deleteCachedFeed() throws {
		
		try performSync { context in
			Result {
				try ManagedFeedCache.deleteCache(in: context)
			}
		}
		
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
		
		try performSync { context in
			Result {
				let managedCache = try ManagedFeedCache.newUniqueInstance(in: context)
				managedCache.timestamp = timestamp
				managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
				try context.save()
			}
		}
	}
}
