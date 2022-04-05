//
//  NetworkMock.swift
//  Natwork_Tests
//
//  Created by Jade Carvalho Silveira on 05/04/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import Natwork
@testable import Natwork_Example

enum MockError: Error {
    case nilResult
    case conversionError
}

final class NetworkMock: Networking {
    typealias U = Decodable
    
    var fetchDataUrlTextWithResultTypeExpectedResult: (Result<U, ApiError>?)
    var fetchDataEndpointExpectedResult: (Result<U, ApiError>?)
    var fetchDataUrlTextExpectedResult: (Result<Data, ApiError>?)
    
    func fetchData<T>(urlText: String,
                      resultType: T.Type,
                      decodingStrategy: JSONDecoder.KeyDecodingStrategy,
                      completion: @escaping (Result<T, ApiError>) -> Void
    ) where T : Decodable {
        do {
            let expectedResult: Result<T, ApiError> = try verify(expectedResult: fetchDataUrlTextWithResultTypeExpectedResult)
            completion(expectedResult)
        } catch {
            XCTFail("Expected result was not satisfied. \(error)")
        }
    }
    
    func fetchData<T>(endpoint: EndpointProtocol,
                      resultType: T.Type,
                      completion: @escaping (Result<T, ApiError>) -> Void
    ) where T : Decodable {
        do {
            let expectedResult: Result<T, ApiError> = try verify(expectedResult: fetchDataEndpointExpectedResult)
            completion(expectedResult)
        } catch {
            XCTFail("Expected result was not satisfied. \(error)")
        }
    }
    
    func fetchData(urlText: String, completion: @escaping (Result<Data, ApiError>) -> Void) {
        do {
            let expectedResult: Result<Data, ApiError> = try verify(expectedResult: fetchDataUrlTextExpectedResult)
            completion(expectedResult)
        } catch {
            XCTFail("Expected result was not satisfied. \(error)")
        }
    }
    
    private func verify<V, W>(expectedResult: Result<V, ApiError>?) throws -> Result<W, ApiError> {
        guard let expectedResult = expectedResult else {
            throw MockError.nilResult
        }
        switch expectedResult {
        case .success(let result):
            guard let convertedResult = result as? W else {
                throw MockError.conversionError
            }
            return .success(convertedResult)
            
        case .failure(let error):
            return .failure(error)
        }
    }
}
