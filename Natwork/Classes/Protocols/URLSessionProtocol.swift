//
//  SessionProtocol.swift
//  NetworkCore
//
//  Created by Jade Silveira on 01/12/21.
//

public typealias URLSessionCompletion = (data: Data?, response: URLResponse?, error: Error?)
public typealias URLSessionCompletion2 = (Data?, URLResponse?, Error?) -> Void

public protocol URLSessionProtocol {
    func fetchData(with url: URL, completionHandler: @escaping (URLSessionCompletion) -> Void)
    func fetchData(with urlRequest: URLRequest, completionHandler: @escaping (URLSessionCompletion) -> Void)
}
