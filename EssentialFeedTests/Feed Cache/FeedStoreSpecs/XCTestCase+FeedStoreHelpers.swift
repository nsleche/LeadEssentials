//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

extension XCTestCase {
    func uniqueImageFeed() -> [LocalFeedImage] {
        return [uniqueImage(), uniqueImage()]
    }
    
    func uniqueImage() -> LocalFeedImage {
        return LocalFeedImage(feedId: UUID(), description: "any description", location: "any location", url: anyURL())
    }
    
    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
		
		do {
			try sut.insert(cache.feed, timestamp: cache.timestamp)
			return nil
		} catch {
			return error
		}
		
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
		do {
			try sut.deleteCachedFeed()
			return nil
		} catch {
			return error
		}
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: Result<CachedFeed?, Error>, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: Result<CachedFeed?, Error>, file: StaticString = #filePath, line: UInt = #line) {
		
		let retrievedResult = Result { try sut.retrieve() }
		
		switch (expectedResult, retrievedResult) {
		case (.success(.none), .success(.none)), (.failure, .failure): break
		case let (.success(.some(expected)), .success(.some(retrieved))):
			XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
			XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
		default:
			XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
		}

    }
}
