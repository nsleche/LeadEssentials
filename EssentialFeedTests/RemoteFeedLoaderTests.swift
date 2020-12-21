//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Alves on 12/15/20.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://awss.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://awss.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
        
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [100, 199, 300, 400, 500]
        
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithResult: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyJSONData = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyJSONData)
        }
    }
    
    func test_load_deliverFeedItemsOn200HTTPResponseWithJSONItems() {
        
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem(feedId: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-url.com")!)
        
        let item1JSON: [String: Any] = [
            "feedId": item1.feedId.uuidString,
            "image": item1.imageURL.absoluteString
        ]
        
        let item2 = FeedItem(feedId: UUID(), description: "item 2 descrition", location: "item 2 location", imageURL: URL(string: "https://a-different-url.com")!)
        
        let item2JSON: [String: Any] = [
            "feedId": item2.feedId.uuidString,
            "description": item2.description!,
            "location": item2.location!,
            "image": item2.imageURL.absoluteString
        ]
        
        let itemsJSON: [String: Any] = ["items": [item1JSON, item2JSON]]
        
        
        expect(sut, toCompleteWithResult: .success([item1, item2])) {
            let jsonData = try! JSONSerialization.data(withJSONObject: itemsJSON, options: .fragmentsAllowed)
            client.complete(withStatusCode: 200, data: jsonData)
        }
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.RemoteFeedLoaderResult, when action: () -> Void) {
        var capturedResults = [RemoteFeedLoader.RemoteFeedLoaderResult]()
        sut.load { capturedResults.append($0) }
        action()
        XCTAssertEqual(capturedResults, [result])
    }
    
    private func makeSUT(url: URL = URL(string: "https://awss.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        return (sut: remoteFeedLoader, client: client)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url: url, completion: completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let responseError = HTTPURLResponse(url: messages[index].url, statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, responseError))
        }
    }
    
}
