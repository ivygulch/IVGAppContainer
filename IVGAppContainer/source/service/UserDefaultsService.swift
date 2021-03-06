//
//  UserDefaultsService.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/21/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation

public protocol UserDefaultsServiceType {
    func value<T>(_ key: String, valueType: T.Type) -> T?
    func setValue<T>(_ value: T, forKey key: String)
    func removeValueForKey(_ key: String)

    func register(defaults: [String: Any])
}

public class UserDefaultsService: UserDefaultsServiceType {

    public convenience init(container: ApplicationContainerType) {
        self.init(container: container, userDefaults: UserDefaults.standard)
    }

    public init(container: ApplicationContainerType, userDefaults: UserDefaults) {
        self.container = container
        self.userDefaults = userDefaults
    }

    public func value<T>(_ key: String, valueType: T.Type) -> T? {
        if T.self == String.self {
            return userDefaults.string(forKey: key) as! T?
        } else if T.self == Int.self {
            return userDefaults.integer(forKey: key) as? T
        } else if T.self == Float.self {
            return userDefaults.float(forKey: key) as? T
        } else if T.self == Double.self {
            return userDefaults.double(forKey: key) as? T
        } else if T.self == Bool.self {
            return userDefaults.bool(forKey: key) as? T
        } else if T.self == URL.self {
            return userDefaults.url(forKey: key) as? T
        } else if T.self == Date.self {
            if userDefaults.object(forKey: key) == nil {
                return nil
            }
            let timeInterval = userDefaults.double(forKey: key) as Double
            return Date(timeIntervalSinceReferenceDate: timeInterval) as? T
        }

        return nil
    }

    public func setValue<T>(_ value: T, forKey key: String) {
        if let value = value as? String {
            userDefaults.set(value, forKey: key)
        } else if let value = value as? Int {
            userDefaults.set(value, forKey: key)
        } else if let value = value as? Float {
            userDefaults.set(value, forKey: key)
        } else if let value = value as? Double {
            userDefaults.set(value, forKey: key)
        } else if let value = value as? Bool {
            userDefaults.set(value, forKey: key)
        } else if let value = value as? URL {
            userDefaults.set(value, forKey: key)
        } else if let value = value as? Date {
            userDefaults.set(value.timeIntervalSinceReferenceDate, forKey: key)
        }
    }

    public func removeValueForKey(_ key: String) {
        userDefaults.removeObject(forKey: key)
    }

    public func willResignActive() {
        userDefaults.synchronize()
    }

    public func register(defaults: [String: Any]) {
        userDefaults.register(defaults: defaults)
    }

    // MARK: private variables

    private let container: ApplicationContainerType
    private let userDefaults: UserDefaults
}
