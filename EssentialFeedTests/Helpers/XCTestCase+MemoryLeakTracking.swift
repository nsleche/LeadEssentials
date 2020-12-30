//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Antonio Alves on 12/22/20.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "instance should have been DEALOCATED. Potential memory leak", file: file, line: line)
        }
    }
}
