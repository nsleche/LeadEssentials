//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Antonio Alves on 12/23/20.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: testServerURL, client: client)
        
        let exp = expectation(description: "wait to load feed items")
        var receivedResult: LoadFeedResult?
        loader.load { (result) in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        switch receivedResult {
        case let .success(feedItems)?:
            XCTAssertEqual(feedItems.count, 8)
        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead")

        default:
            XCTFail("Expected successful feed result, got no result instead")
            
        }
    }

}
