//
//  Endpoint.swift
//  Natwork_Example
//
//  Created by Jade Carvalho Silveira on 04/04/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Natwork

enum Endpoint: EndpointProtocol {
    case searchBy(id: Int)
    case update(id: Int, request: Request)
    
    var host: String { "www.somehost.com" }
    
    var path: String {
        switch self {
        case .searchBy(let id):
            return "/search?id=\(id)"
            
        case .update:
            return "/update"
        }
    }
    
    var headers: [EndpointHeader] { [] }
    
    var params: [String: Any] {
        switch self {
        case .searchBy:
            return [:]
            
        case .update(let id, let request):
            return ["id": id, "name": request.name]
        }
    }
    
    var method: EndpointMethod {
        switch self {
        case .searchBy:
            return .get
            
        case .update:
            return .post
        }
    }
    
    var decodingStrategy: JSONDecoder.KeyDecodingStrategy { .convertFromSnakeCase }
}
