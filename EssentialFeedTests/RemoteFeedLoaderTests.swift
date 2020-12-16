//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Alves on 12/15/20.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoader {
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        _ = RemoteFeedLoader()
        let client = HTTPClient()
        XCTAssertNil(client.requestedURL)
    }

}
