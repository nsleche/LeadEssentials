//
//  ManagedFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Antonio Alves on 1/11/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedFeedImage)
public class ManagedFeedImage: NSManagedObject {

	@NSManaged public var id: UUID
	@NSManaged public var imageDescription: String?
	@NSManaged public var location: String?
	@NSManaged public var url: URL
	@NSManaged public var cache: ManagedFeedCache

}

extension ManagedFeedImage {
	
	static func images(from feed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
		let images = NSOrderedSet(array: feed.map { local in
			let managedImage = ManagedFeedImage(context: context)
            managedImage.id = local.feedId
			managedImage.imageDescription = local.description
			managedImage.location = local.location
			managedImage.url = local.url
			return managedImage
		})
		
		return images
	}
	
	var local: LocalFeedImage {
        return LocalFeedImage(feedId: id, description: imageDescription, location: location, url: url)
	}
	
}
