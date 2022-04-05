//
//  Request+Extensions.swift
//  Natwork_Tests
//
//  Created by Jade Carvalho Silveira on 05/04/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

extension Request {
    static func fixture(id: Int = 1, name: String = "Natwork") -> Request {
        .init(id: id, name: name)
    }
}
