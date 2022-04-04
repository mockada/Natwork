//
//  SessionProtocol.swift
//  NetworkCore
//
//  Created by Jade Silveira on 01/12/21.
//

public protocol SessionProtocol {
    func fetchData(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    func fetchData(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}
