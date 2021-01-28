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
        
        expect(sut, toLoad: [])
        
    }
    
    func test_load_deliversItemsSaveOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        persist(feed, with: sutToPerformSave)
        
        expect(sutToPerformLoad, toLoad: feed)
        
    }
    
    func test_save_overridesitemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformSecondSave = makeSUT()
        let sutToLoad = makeSUT()
        
        let firstFeed = uniqueImageFeed().models
        let secondFeed = uniqueImageFeed().models
        
        persist(firstFeed, with: sutToPerformFirstSave)
        persist(secondFeed, with: sutToPerformSecondSave)
        expect(sutToLoad, toLoad: secondFeed)
        
    }
    
    private func persist(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        do {
            try loader.save(feed)
            XCTAssert(true)
        } catch {
            XCTFail("failed to perform save with error: \(error)")
        }
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        //let exp = expectation(description: "wait for feed to load")
        do {
            let feed = try sut.load()
            XCTAssertEqual(feed, expectedFeed)
        } catch {
            XCTFail("failed to perform load with error: \(error)")
        }
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
