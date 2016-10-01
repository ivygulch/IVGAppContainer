//
//  ApplicationContainer.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import IVGRouter

public enum ContainerState {
    case Uninitialized
    case Launching
    case Inactive
    case Active
    case Background
    case Terminating
}

public protocol ApplicationContainerType: class {
    init(window: UIWindow?)
    var window: UIWindow? { get }
    var containerState: ContainerState { get }
    var router: RouterType { get }
    var startupAction: (Void -> Void)? { get }
    func executeStartupAction()

    var resourceCount: Int { get }
    func resource<T>(type: T.Type) -> T?
    func addResource<T>(resource: ResourceType, forProtocol: T.Type)
    var serviceCount: Int { get }
    func service<T>(type: T.Type) -> T?
    func addService<T>(service: Any, forProtocol: T.Type)
    var coordinatorCount: Int { get }
    func coordinator<T>(type: T.Type) -> T?
    func addCoordinator<T>(coordinator: CoordinatorType, forProtocol: T.Type)

    func willFinishLaunching() -> Bool
    func didFinishLaunching() -> Bool
    func didBecomeActive()
    func willResignActive()
    func willTerminate()
    func didEnterBackground()
    func willEnterForeground()
}

public class ApplicationContainer : ApplicationContainerType {

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

    public let router:RouterType

    public required init(window: UIWindow?) {
        self.window = window
        router = Router(window: window)
        router.registerDefaultPresenters()
    }

    public var startupAction: (Void -> Void)?

    public func executeStartupAction() {
        if let startupAction = startupAction {
            startupAction()
        } else {
            print("WARNING: startupAction is undefined")
        }
    }

    // MARK: - Resources

    public var resources: [ResourceType] {
        return Array(resourcesMap.values)
    }

    public var resourceCount: Int {
        return synchronizer.valueOf {
            return self.resourcesMap.count
        }
    }

    public func resource<T>(type: T.Type) -> T? {
        return synchronizer.valueOf {
            return self.resourcesMap[TypeKey(type)] as? T
        }
    }

    public func addResource<T>(resource: ResourceType, forProtocol: T.Type) {
        synchronizer.execute {
            self.resourcesMap[TypeKey(T)] = resource
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

    public func service<T>(type: T.Type) -> T? {
        return synchronizer.valueOf {
            return self.servicesMap[TypeKey(T)] as? T
        }
    }

    public func addService<T>(service: Any, forProtocol: T.Type) {
        synchronizer.execute {
            let key = TypeKey(T)
            if let index = self.serviceKeyOrder.indexOf(key) {
                self.serviceKeyOrder.removeAtIndex(index)
            }
            self.servicesMap[key] = service
            self.serviceKeyOrder.append(key)

            guard let lifeCycleService = service as? LifeCycleType else {
                return
            }

            // if container state has progressed past uninitialized, then call methods that were missed
            switch self._containerState {
            case .Launching:
                lifeCycleService.willFinishLaunching()
            case .Inactive:
                lifeCycleService.willFinishLaunching()
                lifeCycleService.didFinishLaunching()
            case .Active:
                lifeCycleService.willFinishLaunching()
                lifeCycleService.didFinishLaunching()
                lifeCycleService.didBecomeActive()
            case .Background:
                lifeCycleService.willFinishLaunching()
                lifeCycleService.didFinishLaunching()
                lifeCycleService.didEnterBackground()
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

    public func coordinator<T>(type: T.Type) -> T? {
        return synchronizer.valueOf {
            return self.coordinatorsMap[TypeKey(T)] as? T
        }
    }

    public func addCoordinator<T>(coordinator: CoordinatorType, forProtocol: T.Type) {
        synchronizer.execute {
            self.coordinatorsMap[TypeKey(T)] = coordinator
        }
        coordinator.registerRouteSegments(router)
    }

    // MARK: - Lifecycle

    private func orderedServices() -> [Any] {
        return synchronizer.valueOf {
            return self.serviceKeyOrder
                .filter { self.servicesMap[$0] != nil }
                .map { self.servicesMap[$0]! }
        }
    }

    private func conditionallyForEachLifeCycleService(block: (LifeCycleType) -> Bool) -> Bool {
        for service in orderedServices() {
            if let lifeCycleService = service as? LifeCycleType {
                if !block(lifeCycleService) {
                    return false
                }
            }
        }
        return true
    }

    private func forEachOrderedLifeCycleService(block: (LifeCycleType) -> Void) {
        for service in orderedServices() {
            if let lifeCycleService = service as? LifeCycleType {
                block(lifeCycleService)
            }
        }
    }

    public func willFinishLaunching() -> Bool {
        containerState = .Launching
        return conditionallyForEachLifeCycleService {
            service -> Bool in
            return service.willFinishLaunching()
        }
    }

    public func didFinishLaunching() -> Bool {
        containerState = .Inactive
        return conditionallyForEachLifeCycleService {
            service -> Bool in
            return service.didFinishLaunching()
        }
    }

    public func didBecomeActive() {
        containerState = .Active
        return forEachOrderedLifeCycleService {
            service in
            service.didBecomeActive()
        }
    }

    public func willResignActive() {
        containerState = .Inactive
        return forEachOrderedLifeCycleService {
            service in
            service.willResignActive()
        }
    }

    public func willTerminate() {
        containerState = .Terminating
        return forEachOrderedLifeCycleService {
            service in
            service.willTerminate()
        }
    }

    public func didEnterBackground() {
        containerState = .Background
        return forEachOrderedLifeCycleService {
            service in
            service.didEnterBackground()
        }
    }

    public func willEnterForeground() {
        containerState = .Inactive
        return forEachOrderedLifeCycleService {
            service in
            service.willEnterForeground()
        }
    }

    // MARK: - Private variables

    private var resourcesMap: [TypeKey: ResourceType] = [:]
    private var servicesMap: [TypeKey: Any] = [:]
    private var serviceKeyOrder: [TypeKey] = []
    private var coordinatorsMap: [TypeKey: CoordinatorType] = [:]
    private let synchronizer = Synchronizer()
    private var _containerState: ContainerState = .Uninitialized
}
