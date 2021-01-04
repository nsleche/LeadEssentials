//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Antonio Alves on 1/3/21.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "https://www.google.com")!
}
