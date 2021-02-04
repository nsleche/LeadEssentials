//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Alves on 2/3/21.
//

import XCTest

final class FeedViewController {
    
    let loader: FeedViewControllerTests.LoaderSpy
    init(loader: FeedViewControllerTests.LoaderSpy) {
        self.loader = loader
    }
    
}

class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let sut = makeSUT()
        XCTAssertEqual(sut.loader.loadAllCount, 0)
    }
    
    
    private func makeSUT() -> FeedViewController {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        return sut
    }
    
    class LoaderSpy {
        private(set) var loadAllCount: Int = 0
    }
}
