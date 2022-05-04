//
//  Service.swift
//  Natwork_Example
//
//  Created by Jade Carvalho Silveira on 04/04/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Natwork

struct Response: Decodable, Equatable {
    let name: String
}

struct Request: Decodable, Equatable {
    let id: Int
    let name: String
}

final class Service {
    private let network: Networking
    
    init(network: Networking) {
        self.network = network
    }
    
    func fetchData(completion: @escaping (Result<[Response], ApiError>) -> Void) {
        network.fetchData(
            endpoint: SearchByIdEndpoint(id: 1),
            resultType: [Response].self
        ){ result in
            completion(result)
        }
    }
    
    func updateData(request: Request, completion: @escaping (Result<Response, ApiError>) -> Void) {
        network.fetchData(
            endpoint: UpdateRequestEndpoint(id: 1, request: request),
            resultType: Response.self
        ){ result in
            completion(result)
        }
    }
}
