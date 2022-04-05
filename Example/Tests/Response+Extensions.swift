//
//  Response+Extensions.swift
//  Natwork_Tests
//
//  Created by Jade Carvalho Silveira on 05/04/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

extension Response {
    static func fixture(name: String = "Natwork") -> Response {
        .init(name: name)
    }
}
