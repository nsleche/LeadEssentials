//
//  ManagedFeedCache.swift
//  FeedStoreChallenge
//
//  Created by Antonio Alves on 1/11/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedFeedCache)
public class ManagedFeedCache: NSManagedObject {

	@NSManaged public var timestamp: Date
	@NSManaged public var feed: NSOrderedSet
	
}

extension ManagedFeedCache {
	
	static func find(in context: NSManagedObjectContext) throws -> ManagedFeedCache? {
		let request = NSFetchRequest<ManagedFeedCache>(entityName: entity().name!)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}
	
	static func deleteCache(in context: NSManagedObjectContext) throws {
		try find(in: context).map(context.delete).map(context.save)
	}
	
	static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedFeedCache {
		try deleteCache(in: context)
		return ManagedFeedCache(context: context)
	}
	
	var localFeed: [LocalFeedImage] {
		return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
	}
	
}
