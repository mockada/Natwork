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

private final class DispatchQueueDummy: DispatchQueueProtocol {
    func callAsync(group: DispatchGroup?, qos: DispatchQoS, flags: DispatchWorkItemFlags, execute work: @escaping () -> Void) {
        work()
    }
}

private enum EmptyEndpointStub: EndpointProtocol {
    case endpoint
    
    var host: String { "" }
    var path: String { "" }
    var headers: [EndpointHeader] { [] }
    var params: [String : Any] { ["": ""] }
    var method: EndpointMethod { .post }
    var decodingStrategy: JSONDecoder.KeyDecodingStrategy { .useDefaultKeys }
}

private enum ValidEndpointStub: EndpointProtocol {
    case endpoint
    
    var host: String { "www.host.com" }
    var path: String { "/path" }
    var headers: [EndpointHeader] { [.init(value: "", field: "")] }
    var params: [String : Any] { ["param": "value"] }
    var method: EndpointMethod { .post }
    var decodingStrategy: JSONDecoder.KeyDecodingStrategy { .useDefaultKeys }
}

private struct ResponseStub: Decodable, Equatable { }

final class NetworkTests: XCTestCase {
    private var urlSessionMock: URLSessionMock?
    private var dispatchQueueDummy: DispatchQueueDummy?
    private var sut: Networking?
    
    override func setUp() {
        urlSessionMock = URLSessionMock()
        dispatchQueueDummy = DispatchQueueDummy()
        
        guard let urlSessionMock = urlSessionMock, let dispatchQueueDummy = dispatchQueueDummy else { return }
        sut = Network(session: urlSessionMock, callbackQueue: dispatchQueueDummy)
        super.setUp()
    }

    override func tearDown() {
        urlSessionMock = nil
        dispatchQueueDummy = nil
        sut = nil
        super.tearDown()
    }
}

// MARK: - Fetch data with url text -> Response

extension NetworkTests {
    func testfetchDataUrlText_WhenEmptyEndpoint_ShouldReturnFailureWithUrlParse() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        
        sut?.fetchData(
            urlText: EmptyEndpointStub.endpoint.url,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.urlParse))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataUrlText_WhenValidEndpoint_AndGenericError_ShouldReturnFailureWithServerError() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: Data(), response: URLResponse(), error: ApiError.generic)
        urlSessionMock?.fetchDataWithUrlExpectedResult = completion
        
        sut?.fetchData(
            urlText: ValidEndpointStub.endpoint.url,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.server(error: ApiError.generic)))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataUrlText_WhenValidEndpoint_AndNilResponse_ShouldReturnFailureWithNilResponse() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: Data(), response: nil, error: nil)
        urlSessionMock?.fetchDataWithUrlExpectedResult = completion
        
        sut?.fetchData(
            urlText: ValidEndpointStub.endpoint.url,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.nilResponse))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataUrlText_WhenValidEndpoint_AndResponseWithClientErrorStatusCode_ShouldReturnFailureWithStatusCode() {
        guard let url = URL(string: "www.google.com") else { return }
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let response: HTTPURLResponse? = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        let completion: URLSessionCompletion = (data: Data(), response: response, error: nil)
        urlSessionMock?.fetchDataWithUrlExpectedResult = completion
        
        sut?.fetchData(
            urlText: ValidEndpointStub.endpoint.url,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.statusCode(code: .clientError)))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataUrlText_WhenValidEndpoint_AndNilData_ShouldReturnFailureWithNilData() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: nil, response: HTTPURLResponse(), error: nil)
        urlSessionMock?.fetchDataWithUrlExpectedResult = completion
        
        sut?.fetchData(
            urlText: ValidEndpointStub.endpoint.url,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.nilData))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataUrlText_WhenValidEndpoint_AndCouldNotConvertDataToResultType_ShouldReturnFailureWithJsonParse() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: Data(), response: HTTPURLResponse(), error: nil)
        urlSessionMock?.fetchDataWithUrlExpectedResult = completion
        
        sut?.fetchData(
            urlText: ValidEndpointStub.endpoint.url,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.jsonParse))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataUrlText_WhenValidEndpoint_AndCouldConvertDataToResultType_AndHasHTTPURLResponse_AndErrorIsNil_ShouldReturnSuccess() {
        guard let data: Data = "{}".data(using: .utf8) else { return }
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: data, response: HTTPURLResponse(), error: nil)
        urlSessionMock?.fetchDataWithUrlExpectedResult = completion
        
        sut?.fetchData(
            urlText: ValidEndpointStub.endpoint.url,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .success(.init()))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
}

// MARK: - Fetch data with endpoint -> Response

extension NetworkTests {
    func testfetchDataEndpoint_WhenEmptyEndpoint_ShouldReturnFailureWithUrlParse() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        
        sut?.fetchData(
            endpoint: EmptyEndpointStub.endpoint,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.urlParse))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataEndpoint_WhenValidEndpoint_AndGenericError_ShouldReturnFailureWithServerError() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: Data(), response: URLResponse(), error: ApiError.generic)
        urlSessionMock?.fetchDataWithUrlRequestExpectedResult = completion
        
        sut?.fetchData(
            endpoint: ValidEndpointStub.endpoint,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.server(error: ApiError.generic)))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataEndpoint_WhenValidEndpoint_AndNilResponse_ShouldReturnFailureWithNilResponse() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: Data(), response: nil, error: nil)
        urlSessionMock?.fetchDataWithUrlRequestExpectedResult = completion
        
        sut?.fetchData(
            endpoint: ValidEndpointStub.endpoint,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.nilResponse))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataEndpoint_WhenValidEndpoint_AndResponseWithClientErrorStatusCode_ShouldReturnFailureWithStatusCode() {
        guard let url = URL(string: ValidEndpointStub.endpoint.url) else { return }
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let response: HTTPURLResponse? = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        let completion: URLSessionCompletion = (data: Data(), response: response, error: nil)
        urlSessionMock?.fetchDataWithUrlRequestExpectedResult = completion
        
        sut?.fetchData(
            endpoint: ValidEndpointStub.endpoint,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.statusCode(code: .clientError)))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataEndpoint_WhenValidEndpoint_AndNilData_ShouldReturnFailureWithNilData() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: nil, response: HTTPURLResponse(), error: nil)
        urlSessionMock?.fetchDataWithUrlRequestExpectedResult = completion
        
        sut?.fetchData(
            endpoint: ValidEndpointStub.endpoint,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.nilData))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataEndpoint_WhenValidEndpoint_AndCouldNotConvertDataToResultType_ShouldReturnFailureWithJsonParse() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: Data(), response: HTTPURLResponse(), error: nil)
        urlSessionMock?.fetchDataWithUrlRequestExpectedResult = completion
        
        sut?.fetchData(
            endpoint: ValidEndpointStub.endpoint,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .failure(.jsonParse))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataEndpoint_WhenValidEndpoint_AndCouldConvertDataToResultType_AndHasHTTPURLResponse_AndErrorIsNil_ShouldReturnSuccess() {
        guard let data: Data = "{}".data(using: .utf8) else { return }
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: data, response: HTTPURLResponse(), error: nil)
        urlSessionMock?.fetchDataWithUrlRequestExpectedResult = completion
        
        sut?.fetchData(
            endpoint: ValidEndpointStub.endpoint,
            resultType: ResponseStub.self
        ) { result in
            XCTAssertEqual(result, .success(.init()))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
}

// MARK: - Fetch data with url text -> Data

extension NetworkTests {
    func testfetchDataUrlText_WhenEmptyUrlText_ShouldReturnFailureWithUrlParse() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: Data(), response: nil, error: nil)
        urlSessionMock?.fetchDataWithUrlExpectedResult = completion
        
        sut?.fetchData(
            urlText: EmptyEndpointStub.endpoint.url
        ) { result in
            XCTAssertEqual(result, .failure(.urlParse))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataUrlText_WhenValidUrlText_AndDataIsNil_ShouldReturnFailureWithNilData() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: nil, response: HTTPURLResponse(), error: nil)
        urlSessionMock?.fetchDataWithUrlExpectedResult = completion
        
        sut?.fetchData(
            urlText: ValidEndpointStub.endpoint.url
        ) { result in
            XCTAssertEqual(result, .failure(.nilData))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataUrlText_WhenValidUrlText_AndResponseIsNil_ShouldReturnFailureWithNilResponse() {
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: Data(), response: nil, error: nil)
        urlSessionMock?.fetchDataWithUrlExpectedResult = completion
        
        sut?.fetchData(
            urlText: ValidEndpointStub.endpoint.url
        ) { result in
            XCTAssertEqual(result, .failure(.nilResponse))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testfetchDataUrlText_WhenValidUrlText_AndDataIsNotNil_AndResponseIsNotNil_ShouldReturnSuccess() {
        guard let data: Data = "{}".data(using: .utf8) else { return }
        let expectation: XCTestExpectation = XCTestExpectation(description: "fetchDataEndpointExpectedResult")
        let completion: URLSessionCompletion = (data: data, response: HTTPURLResponse(), error: nil)
        urlSessionMock?.fetchDataWithUrlExpectedResult = completion
        
        sut?.fetchData(
            urlText: ValidEndpointStub.endpoint.url
        ) { result in
            XCTAssertEqual(result, .success(data))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
}
