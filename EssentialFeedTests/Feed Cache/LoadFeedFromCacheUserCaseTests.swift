//
//  LoadFeedFromCacheUserCaseTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Alves on 12/31/20.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUserCaseTests: XCTestCase {
    
    func test_init() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load {_ in}
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWithResult: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImageOnEmptyCache() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWithResult: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedImagesOnLessThan7DaysOldCache() {
        let feed = uniqueImageFeed()
        
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: 7).adding(seconds: 1)
        
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        // i better learn and apply this course, cause i'm spending a lot
        expect(sut, toCompleteWithResult: .success(feed.model)) {
            store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        }
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithResult expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "waiting for load")
        
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems)
            case let (.failure(receivedError as NSError?), .failure(expectedError as NSError?)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("Expected result: \(expectedResult), got: \(receivedResult)")
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    private func anyURL() -> URL {
        return URL(string: "https://www.google.com")!
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(feedId: UUID(), description: "any description", location: "any location", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (model: [FeedImage], local: [LocalFeedImage]) {
        let model = [uniqueImage(), uniqueImage()]
        let local = model.map { LocalFeedImage(feedId: $0.feedId, description: $0.description, location: $0.location, url: $0.url)}
        return (model, local)
    }
    
}

private extension Date {
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: Double) -> Date {
        return self + seconds
    }
}
