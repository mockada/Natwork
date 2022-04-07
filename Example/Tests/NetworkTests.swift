//
//  NetworkTests.swift
//  Natwork_Tests
//
//  Created by Jade Carvalho Silveira on 05/04/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import Natwork
@testable import Natwork_Example

private final class URLSessionMock: URLSessionProtocol {
    var fetchDataWithUrlExpectedResult: URLSessionCompletion?
    var fetchDataWithUrlRequestExpectedResult: URLSessionCompletion?

    func fetchData(with url: URL, completionHandler: @escaping (URLSessionCompletion) -> Void) {
        guard let fetchDataWithUrlExpectedResult = fetchDataWithUrlExpectedResult else { return }
        completionHandler(fetchDataWithUrlExpectedResult)
    }

    func fetchData(with urlRequest: URLRequest, completionHandler: @escaping (URLSessionCompletion) -> Void) {
        guard let fetchDataWithUrlRequestExpectedResult = fetchDataWithUrlRequestExpectedResult else { return }
        completionHandler(fetchDataWithUrlRequestExpectedResult)
    }
}

private final class DispatchQueueMock: DispatchQueueProtocol {
    var executeCallAsync: (() -> Void)?
    
    func callAsync(execute work: @escaping () -> Void) {
        guard let executeCallAsync = executeCallAsync else {
            return
        }
        callAsync(execute: executeCallAsync)
    }
}

private enum EndpointStub: EndpointProtocol {
    case endpointCase
    
    var host: String { "www.host.com" }
    var path: String { "/path" }
    var headers: [EndpointHeader] { [.init(value: "", field: "")] }
    var params: [String : Any] { ["param": "value"] }
    var method: EndpointMethod { .post }
    var decodingStrategy: JSONDecoder.KeyDecodingStrategy { .useDefaultKeys }
}

private struct ResponseStub: Decodable, Equatable {
    
}

final class NetworkTests: XCTestCase {
    private var urlSessionMock: URLSessionMock?
    private var dispatchQueueMock: DispatchQueueMock?
    private var sut: Networking?
    
    override func setUp() {
        urlSessionMock = URLSessionMock()
        dispatchQueueMock = DispatchQueueMock()
        
        guard let urlSessionMock = urlSessionMock, let dispatchQueueMock = dispatchQueueMock else { return }
        sut = Network(session: urlSessionMock, callbackQueue: dispatchQueueMock)
        super.setUp()
    }

    override func tearDown() {
        urlSessionMock = nil
        dispatchQueueMock = nil
        sut = nil
        super.tearDown()
    }
}

extension NetworkTests {
    func testFetchData() {
        let expectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: Data(), response: URLResponse(), error: ApiError.generic)
        urlSessionMock?.fetchDataWithUrlRequestExpectedResult = completion
        dispatchQueueMock?.executeCallAsync = something
        
        sut?.fetchData(endpoint: EndpointStub.endpointCase,
                       resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.server(error: ApiError.generic)))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func something() {
        print("something")
    }
}
