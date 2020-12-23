//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Alves on 12/22/20.
//

import Foundation
import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, _ result: @escaping (HTTPClientResult) -> Void = { _ in }) {
        session.dataTask(with: url) { (_, _, error) in
            if let error = error {
                result(.failure(error))
                print("error", error)
            }
        }.resume()
    }
}


class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://www.google.com")!
        let error = NSError(domain: "none", code: 400, userInfo: nil)
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)
                
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                var a = NSError(domain: receivedError.domain, code: receivedError.code, userInfo: nil)
                XCTAssertEqual(error, a)
            case .success:
                XCTFail("Expected failure with error: \(error), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private final class URLProtocolStub: URLProtocol {
        
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
            let data: Data?
            let response: HTTPURLResponse?
        }
        
        static func stub(url: URL, data: Data?, response: HTTPURLResponse?, error: Error?) {
            stubs[url] = Stub(error: error, data: data, response: response)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
}
