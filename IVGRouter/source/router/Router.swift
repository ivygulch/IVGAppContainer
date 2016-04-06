//
//  Router.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/22/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public protocol RouterType {
    var window: UIWindow? { get }
    var routeSegments:[Identifier:RouteSegmentType] { get }
    var presenters:[Identifier:RouteSegmentPresenterType] { get }
    var viewControllers:[UIViewController] { get }
    func registerRouteSegment(routeSegment:RouteSegmentType)
    func executeRoute(identifiers:[Identifier]) -> Bool
}

public class Router : RouterType {

    public init(window: UIWindow?) {
        self.window = window
    }

    public private(set) var routeSegments:[Identifier:RouteSegmentType] = [:]
    public private(set) var presenters:[Identifier:RouteSegmentPresenterType] = [:]

    public let window: UIWindow?

    public var viewControllers:[UIViewController] {
        return currentActiveSegments.map { $0.viewController }
    }

    public func registerPresenter(presenter:RouteSegmentPresenterType) {
        presenters[presenter.presenterIdentifier] = presenter
    }

    public func registerRouteSegment(routeSegment:RouteSegmentType) {
        routeSegments[routeSegment.segmentIdentifier] = routeSegment
    }

    public func executeRoute(identifiers:[Identifier]) -> Bool {
        var newActiveSegments:[ActiveSegment] = []
        var routeChanged = false
        defer {
            currentActiveSegments = newActiveSegments
        }
        var parent: UIViewController?
        for identifierIndex in 0..<identifiers.count {
            let segmentIdentifier = identifiers[identifierIndex]
            guard let routeSegment = routeSegments[segmentIdentifier] else {
                print("No segment registered for: \(segmentIdentifier)")
                return false
            }
            let isLastSegment = (identifierIndex == (identifiers.count - 1))
            let currentActiveSegment:ActiveSegment? = (identifierIndex < currentActiveSegments.count) ? currentActiveSegments[identifierIndex] : nil
            var currentChild = currentActiveSegment?.viewController

            var needNewChild = false
            if currentChild == nil {
                needNewChild = true
            } else if let tabBarController = parent as? UITabBarController,
                sibling = selectSibingInTabBarController(tabBarController, forIdentifier: segmentIdentifier) {
                currentChild = sibling
                needNewChild = false
            } else {
                needNewChild = (segmentIdentifier != currentActiveSegment?.segmentIdentifier)
            }

            var child: UIViewController?
            if routeChanged || needNewChild {
                var completionSucessful = true
                if let presenter = presenters[routeSegment.presenterIdentifier],
                    let viewController = routeSegment.viewController() {
                    child = viewController
                    presenter.presentViewController(viewController, from: parent, withWindow: window, completion: {
                        success in
                        completionSucessful = success
                    })
                }
                if child == nil {
                    print("Route segment did not load a viewController: \(segmentIdentifier)")
                    return false
                }
                if !completionSucessful {
                    print("Route segment completion block failed: \(segmentIdentifier)")
                    return false
                }
            } else {
                child = currentChild
                // if we are still on the previous path, but on the last segment, check if we can simply pop back in the navigation stack
                if isLastSegment {
                    if let child = child, childNavigationController = child.navigationController {
                        childNavigationController.popToViewController(child, animated: true)
                    }
                }
            }

            if let child = child {
                newActiveSegments.append(ActiveSegment(segmentIdentifier:segmentIdentifier,viewController:child))
                registeredViewControllers[child] = segmentIdentifier
            }

            parent = child

        }
        return true
    }

    private func selectSibingInTabBarController(tabBarController:UITabBarController, forIdentifier segmentIdentifier:Identifier) -> UIViewController? {
        if let existingChildren = tabBarController.viewControllers {
            for index in 0..<existingChildren.count {
                let existingChild = existingChildren[index]
                if registeredViewControllers[existingChild] == segmentIdentifier {
                    tabBarController.selectedIndex = index
                    return existingChild
                }
            }
        }
        return nil
    }

    private var currentActiveSegments:[ActiveSegment] = []
    private var registeredViewControllers:[UIViewController:Identifier] = [:]

}

private struct ActiveSegment {
    let segmentIdentifier: Identifier
    let viewController: UIViewController
}
