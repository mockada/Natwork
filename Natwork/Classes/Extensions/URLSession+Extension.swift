//
//  URLSession+Extension.swift
//  NetworkCore
//
//  Created by Jade Silveira on 01/12/21.
//

extension URLSession: SessionProtocol {
    public func fetchData(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task: URLSessionDataTask = dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
    public func fetchData(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task: URLSessionDataTask = dataTask(with: urlRequest, completionHandler: completionHandler)
        task.resume()
    }
}
