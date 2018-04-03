//
//  Coordinator.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation
import IVGRouter

public protocol CoordinatorType {
    var identifier: Identifier { get }
}

public extension CoordinatorType {
    var identifier: Identifier { return Identifier(name: String(describing: type(of: self))) }
}
