//
//  LifeCycleType.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public protocol LifeCycleType {
    func willFinishLaunching() -> Bool
    func didFinishLaunching() -> Bool
    func didBecomeActive()
    func willResignActive()
    func willTerminate()
    func didEnterBackground()
    func willEnterForeground()
}

// provide default implementations for all methods

public extension LifeCycleType {

    func willFinishLaunching() -> Bool {
        return true
    }

    func didFinishLaunching() -> Bool {
        return true
    }

    func didBecomeActive() {
    }

    func willResignActive() {
    }

    func willTerminate() {
    }

    func didEnterBackground() {
    }

    func willEnterForeground() {
    }

}