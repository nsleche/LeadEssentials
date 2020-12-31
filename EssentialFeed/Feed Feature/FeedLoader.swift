//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Antonio Alves on 12/15/20.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
