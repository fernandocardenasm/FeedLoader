//
//  RemoteFeedLoaderTests.swift
//  FeedLoaderTests
//
//  Created by Fernando Cardenas on 14.02.21.
//

import XCTest
import EssentialFeed

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
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(withError: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: Data(), at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let data = Data(bytes: "invalid json", count: 10)
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            description: "some description",
            location: "some location",
            imageURL: URL(string: "https://some-url.com")!)
        let item2 = makeItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "https://another-url.com")!)
        
        expect(sut, toCompleteWith: .success([item1.model, item2.model])) {
            let data = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDealloacted() {
        let url = URL(string: "https://a-string.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedItems), .success(recievedItems)):
                XCTAssertEqual(expectedItems, recievedItems, file: file, line: line)
            case let (.failure(expectedError as RemoteFeedLoader.Error), .failure(receivedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 0.1)
    }
    
    private func makeItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json: [String: Any?] = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ]
        let mappedJSON = json.compactMapValues { $0 }
        
        return (item, mappedJSON)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

class HTTPClientSpy: HTTPClient {
    
    var messages = [(url: URL, completion: (Result<(Data, HTTPURLResponse), Error>) -> Void)]()
    
    var requestedURLs: [URL] {
        messages.map(\.url)
    }
    
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(withError error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
    }
}
