//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Antonio Alves on 1/22/21.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for load completion")
        
        do {
            let loadedFeed = try sut.load()
            XCTAssertTrue(loadedFeed.isEmpty)
            exp.fulfill()
        } catch {
            XCTFail("failed to perform load with error: \(error)")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_load_deliversItemsSaveOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        let saveExp = expectation(description: "Wait for save result")
        do {
            try sutToPerformSave.save(feed)
            saveExp.fulfill()
        } catch {
            XCTFail("failed to perform save with error: \(error)")
        }
        
        let loadExp = expectation(description: "wait for load result")
        
        do {
            let loadedFeed = try sutToPerformLoad.load()
            XCTAssertEqual(loadedFeed, feed)
            loadExp.fulfill()
        } catch {
            XCTFail("failed to perform load with error: \(error)")
            loadExp.fulfill()
        }
        
        wait(for: [saveExp, loadExp], timeout: 1.0)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
         return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
     }

     private func cachesDirectory() -> URL {
         return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
     }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

}
