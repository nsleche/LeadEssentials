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
        print(self.session.observationInfo)
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
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        
        let url = URL(string: "https://www.google.com")!
        let exp = expectation(description: "wait for completion")
        
        URLProtocolStub.obeserveRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url)
        
        wait(for: [exp], timeout: 3.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://www.google.com")!
        let error = NSError(domain: "none", code: 400, userInfo: nil)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
                
        let exp = expectation(description: "wait for completion")
        
        makeSUT().get(from: url) { result in
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
    
    private func makeSUT() -> URLSessionHTTPClient {
        URLSessionHTTPClient()
    }
    
    private final class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)? = nil
        private struct Stub {
            let error: Error?
            let data: Data?
            let response: HTTPURLResponse?
        }
        
        static func obeserveRequests(_ observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func stub(data: Data?, response: HTTPURLResponse?, error: Error?) {
            stub = Stub(error: error, data: data, response: response)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
}
