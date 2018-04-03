//
//  Identifier.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/3/18.
//  Copyright © 2018 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public func ==(lhs: Identifier, rhs: Identifier) -> Bool {
    return lhs.name == rhs.name
}

public struct Identifier: Hashable {

    public init(name: String) {
        self.name = name
    }

    public let name: String
    public var hashValue: Int { return name.hashValue }
}

