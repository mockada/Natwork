//
//  JSONDecoder+Extension.swift
//  NetworkCore
//
//  Created by Jade Silveira on 01/12/21.
//

public extension JSONDecoder {
    convenience init(keyDecodingStrategy: KeyDecodingStrategy) {
        self.init()
        self.keyDecodingStrategy = keyDecodingStrategy
    }
}
