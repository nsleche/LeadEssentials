//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Alves on 12/22/20.
//

import Foundation
import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {

        let url = anyURL()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.obeserveRequests { request in

            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(from: url) { _ in}

        wait(for: [exp], timeout: 1.0)
    }
    
    
    func test_getFromURL_failsOnRequestError() {
        let error = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: error)
        XCTAssertEqual(receivedError as NSError?, error)
    }
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
    }
    
    func test_getFromURL_successOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let result = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(result?.data, data)
        XCTAssertEqual(result?.response.url, response.url)
        XCTAssertEqual(result?.response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_successWithEmptyDataOnHTTPURLResponseWithNilData() {
        
        let response = anyHTTPURLResponse()
        let result = resultValuesFor(data: nil, response: response, error: nil)
        
        
        let emptyData = Data()
        XCTAssertEqual(result?.data, emptyData)
        XCTAssertEqual(result?.response.url, response.url)
        XCTAssertEqual(result?.response.statusCode, response.statusCode)
        
    }

    private func makeSUT() -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(data: data, response: response, error: error)
                
        switch result {
        case let .success(data, response):
            return (data: data, response: response)
        default:
            XCTFail("Expected success got: \(result) instead", file: file, line: line)
            return nil
        }
        
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
                
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
        case let .failure(error as NSError):
            let actualError = NSError(domain: error.domain, code: error.code, userInfo: nil)
            return actualError
        default:
            XCTFail("Expected failure got: \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT()
        let exp = expectation(description: "wait for complete")
        
        var receivedResult: HTTPClientResult?
        
        sut.get(from: anyURL()) { (result) in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult!
        
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://www.google.com")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    
    private final class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        private struct Stub {
            let error: Error?
            let data: Data?
            let response: URLResponse?
        }
        
        static func obeserveRequests(_ observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
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
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
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
