//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Antonio Alves on 12/31/20.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages: [ReceivedMessage] = []
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    
    private var resultCompletions = [(LocalFeedLoader.LoadResult) -> Void]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        self.deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        receivedMessages.append(.insert(feed, timestamp))
        self.insertionCompletions.append(completion)
    }
    
    func retrieve(completion: @escaping (LocalFeedLoader.LoadResult) -> Void) {
        receivedMessages.append(.retrieve)
        resultCompletions.append(completion)
    }
    
    func completeDeletion(with error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        self.insertionCompletions[index](error)
    }
    
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        self.insertionCompletions[index](nil)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        resultCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        resultCompletions[index](.success([]))
    }
    
}
