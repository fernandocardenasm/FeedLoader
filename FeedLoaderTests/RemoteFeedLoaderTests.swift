//
//  RemoteFeedLoaderTests.swift
//  FeedLoaderTests
//
//  Created by Fernando Cardenas on 14.02.21.
//

import XCTest
import FeedLoader

class RemoteFeedLoaderTests: XCTestCase {
        
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.messages.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://agiven-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestDataFromURLTwice() {
        let url = URL(string: "https://agiven-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let url = URL(string: "https://agiven-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(withError: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0) }
            
            client.complete(withStatusCode: code, at: index)
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
}

class HTTPClientSpy: HTTPClient {
    
    var messages = [(url: URL, completion: (Result<HTTPURLResponse, Error>) -> Void)]()
    
    var requestedURLs: [URL] {
        messages.map(\.url)
    }
    
    func get(url: URL, completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(withError error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success(response))
    }
}
