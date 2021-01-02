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
        let anyError = anyNSError()
        
        
        expect(sut, toCompleteWithResult: .success([])) {
            store.completeRetrieval(with: anyError)
        }
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithResult result: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "waiting for load")
        let anyError = anyNSError()
        
        sut.load() { result in
            switch result {
            case .success:
                XCTFail("Expected to receive test_load_failsOnRetrievalError, received: \(result) instead")
            case let .failure(error):
                XCTAssertEqual(error as NSError?, anyError)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
