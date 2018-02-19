//
//  ApplicationContainer.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import IVGFoundation
import IVGRouter

public enum ContainerState {
    case uninitialized
    case launching
    case inactive
    case active
    case background
    case terminating
}

public protocol ApplicationContainerType: class {
    init(window: UIWindow?)
    var window: UIWindow? { get }
    var containerState: ContainerState { get }
    var routerProvider: RouterProvider? { get }
    var startupAction: (() -> Void)? { get }
    func executeStartupAction()

    var resourceCount: Int { get }
    func resource<T>(_ type: T.Type) -> T?
    func addResource<T>(_ resource: Any, forProtocol: T.Type)
    var serviceCount: Int { get }
    func service<T>(_ type: T.Type) -> T?
    func addService<T>(_ service: Any, forProtocol: T.Type)
    var coordinatorCount: Int { get }
    func coordinator<T>(_ type: T.Type) -> T?
    func addCoordinator<T>(_ coordinator: CoordinatorType, forProtocol: T.Type)

    func willFinishLaunching() -> Bool
    func didFinishLaunching() -> Bool
    func didBecomeActive()
    func willResignActive()
    func willTerminate()
    func didEnterBackground()
    func willEnterForeground()
}

open class ApplicationContainer : ApplicationContainerType {

    public let window: UIWindow?
    public var containerState: ContainerState {
        get {
            return synchronizer.valueOf {
                return self._containerState
            }
        }
        set {
            synchronizer.execute {
                self._containerState = newValue
            }
        }
    }

    public var routerProvider: RouterProvider?
    public var router: RouterType? { return routerProvider?(window) }

    public required init(window: UIWindow?) {
        self.window = window
    }

    public var startupAction: (() -> Void)?

    public func executeStartupAction() {
        if let startupAction = startupAction {
            startupAction()
        } else {
            print("WARNING: startupAction is undefined")
        }
    }

    // MARK: - Resources

    public var resources: [Any] {
        return Array(resourcesMap.values)
    }

    public var resourceCount: Int {
        return synchronizer.valueOf {
            return self.resourcesMap.count
        }
    }

    public func resource<T>(_ type: T.Type) -> T? {
        return synchronizer.valueOf {
            return self.resourcesMap[TypeKey(type)] as? T
        }
    }

    public func addResource<T>(_ resource: Any, forProtocol: T.Type) {
        synchronizer.execute {
            self.resourcesMap[TypeKey(T.self)] = resource
        }
    }

    // MARK: - Services

    public var services: [Any] {
        return Array(servicesMap.values)
    }

    public var serviceCount: Int {
        return synchronizer.valueOf {
            return self.servicesMap.count
        }
    }

    public func service<T>(_ type: T.Type) -> T? {
        return synchronizer.valueOf {
            return self.servicesMap[TypeKey(T.self)] as? T
        }
    }

    public func addService<T>(_ service: Any, forProtocol: T.Type) {
        synchronizer.execute {
            let key = TypeKey(T.self)
            if let index = self.serviceKeyOrder.index(of: key) {
                self.serviceKeyOrder.remove(at: index)
            }
            self.servicesMap[key] = service
            self.serviceKeyOrder.append(key)

            guard let lifeCycleService = service as? LifeCycleType else {
                return
            }

            // if container state has progressed past uninitialized, then call methods that were missed
            switch self._containerState {
            case .launching: 
                _ = lifeCycleService.willFinishLaunching()
            case .inactive: 
                _ = lifeCycleService.willFinishLaunching()
                _ = lifeCycleService.didFinishLaunching()
            case .active: 
                _ = lifeCycleService.willFinishLaunching()
                _ = lifeCycleService.didFinishLaunching()
                _ = lifeCycleService.didBecomeActive()
            case .background: 
                _ = lifeCycleService.willFinishLaunching()
                _ = lifeCycleService.didFinishLaunching()
                _ = lifeCycleService.didEnterBackground()
            default: 
                break // no extra steps necessary
            }
        }
    }

    // MARK: - Coordinators

    public var coordinators: [CoordinatorType] {
        return Array(coordinatorsMap.values)
    }

    public var coordinatorCount: Int {
        return synchronizer.valueOf {
            return self.coordinatorsMap.count
        }
    }

    public func coordinator<T>(_ type: T.Type) -> T? {
        return synchronizer.valueOf {
            return self.coordinatorsMap[TypeKey(T.self)] as? T
        }
    }

    public func addCoordinator<T>(_ coordinator: CoordinatorType, forProtocol: T.Type) {
        synchronizer.execute {
            self.coordinatorsMap[TypeKey(T.self)] = coordinator
        }
    }

    // MARK: - Lifecycle

    private func orderedServices() -> [Any] {
        return synchronizer.valueOf {
            return self.serviceKeyOrder
                .filter { self.servicesMap[$0] != nil }
                .map { self.servicesMap[$0]! }
        }
    }

    private func conditionallyForEachLifeCycleService(_ block: (LifeCycleType) -> Bool) -> Bool {
        for service in orderedServices() {
            if let lifeCycleService = service as? LifeCycleType {
                if !block(lifeCycleService) {
                    return false
                }
            }
        }
        return true
    }

    private func forEachOrderedLifeCycleService(_ block: (LifeCycleType) -> Void) {
        for service in orderedServices() {
            if let lifeCycleService = service as? LifeCycleType {
                block(lifeCycleService)
            }
        }
    }

    public func willFinishLaunching() -> Bool {
        containerState = .launching
        return conditionallyForEachLifeCycleService {
            service -> Bool in
            return service.willFinishLaunching()
        }
    }

    public func didFinishLaunching() -> Bool {
        containerState = .inactive
        return conditionallyForEachLifeCycleService {
            service -> Bool in
            return service.didFinishLaunching()
        }
    }

    public func didBecomeActive() {
        containerState = .active
        return forEachOrderedLifeCycleService {
            service in
            service.didBecomeActive()
        }
    }

    public func willResignActive() {
        containerState = .inactive
        return forEachOrderedLifeCycleService {
            service in
            service.willResignActive()
        }
    }

    public func willTerminate() {
        containerState = .terminating
        return forEachOrderedLifeCycleService {
            service in
            service.willTerminate()
        }
    }

    public func didEnterBackground() {
        containerState = .background
        return forEachOrderedLifeCycleService {
            service in
            service.didEnterBackground()
        }
    }

    public func willEnterForeground() {
        containerState = .inactive
        return forEachOrderedLifeCycleService {
            service in
            service.willEnterForeground()
        }
    }

    // MARK: - Private variables

    private var resourcesMap: [TypeKey: Any] = [: ]
    private var servicesMap: [TypeKey: Any] = [: ]
    private var serviceKeyOrder: [TypeKey] = []
    private var coordinatorsMap: [TypeKey: CoordinatorType] = [: ]
    private let synchronizer = Synchronizer()
    private var _containerState: ContainerState = .uninitialized
}
