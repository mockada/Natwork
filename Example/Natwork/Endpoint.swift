//
//  Endpoint.swift
//  Natwork_Example
//
//  Created by Jade Carvalho Silveira on 04/04/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Natwork

struct SearchByIdEndpoint: EndpointProtocol {
    let id: Int
    
    var path: String { "/search?id=\(id)" }
    let host: String = "www.somehost.com"
    let headers: [EndpointHeader] = []
    let params: [String: Any] = [:]
    let method: EndpointMethod = .get
    let decodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase
}

struct UpdateRequestEndpoint: EndpointProtocol {
    let id: Int
    let request: Request
    
    var params: [String: Any] { ["id": id, "name": request.name] }
    let path: String = "/update"
    let host: String = "www.somehost.com"
    let headers: [EndpointHeader] = []
    let method: EndpointMethod = .post
    let decodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase
}
