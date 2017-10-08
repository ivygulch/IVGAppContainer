//
//  DemoAppCoordinator.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/21/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import Foundation
import IVGAppContainer
import IVGRouter

protocol DemoAppCoordinatorType: CoordinatorType {
}

class DemoAppCoordinator: DemoAppCoordinatorType {

    let rootSegmentIdentifier = Identifier(name: "DemoAppCoordinator.root")
    let welcomeSegmentIdentifier = Identifier(name: "DemoAppCoordinator.welcome")
    let nextSegmentIdentifier = Identifier(name: "DemoAppCoordinator.next")
    let wrapperSegmentIdentifier = Identifier(name: "DemoAppCoordinator.wrapper")

    lazy var welcomeRouteSequence: [Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier]
    lazy var nextRouteSequence: [Any] = [self.rootSegmentIdentifier,self.welcomeSegmentIdentifier,self.nextSegmentIdentifier]

    required init(container: ApplicationContainerType) {
        self.container = container
    }

    func registerRouteSegments(withRouter router: RouterType) {
        router.register(routeSegment: buildRootSegment())
        router.register(routeSegment: buildWelcomeSegment())
        router.register(routeSegment: buildNextSegment())
        router.register(routeSegment: buildWrapperSegment())
    }

    fileprivate func buildRootSegment() -> VisualRouteSegment {
        return VisualRouteSegment(
            segmentIdentifier: rootSegmentIdentifier,
            presenterIdentifier: RootRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController: { { return RootViewController() } }
        )
    }

    fileprivate func buildWelcomeSegment() -> VisualRouteSegment  {
        return VisualRouteSegment(
            segmentIdentifier: welcomeSegmentIdentifier,
            presenterIdentifier: PushRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController: { {
                let result = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: WelcomeViewController.self)) as! WelcomeViewController
                result.nextAction = {
                    self.container.router.execute(route: self.nextRouteSequence) { _ in }
                }
                return result
                } }
        )
    }

    fileprivate func buildNextSegment() -> VisualRouteSegment  {
        return VisualRouteSegment(
            segmentIdentifier: nextSegmentIdentifier,
            presenterIdentifier: PushRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController: { {
                let result = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: NextScreenViewController.self)) as! NextScreenViewController

                result.navigationItem.hidesBackButton = true
                let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.nextScreenBack))
                result.navigationItem.leftBarButtonItem = newBackButton;

                result.returnAction = {
                    self.container.router.execute(route: self.welcomeRouteSequence) { _ in }
                }
                result.wrapAction = {
                    self.container.router.append(route: [self.wrapperSegmentIdentifier]) { _ in }
                }
                return result
                } }
        )
    }

    fileprivate func buildWrapperSegment() -> VisualRouteSegment  {
        return VisualRouteSegment(
            segmentIdentifier: wrapperSegmentIdentifier,
            presenterIdentifier: WrappingRouteSegmentPresenter.defaultPresenterIdentifier,
            isSingleton: true,
            loadViewController: { {
                let result = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: WrapperViewController.self)) as! WrapperViewController

                result.unwrapAction = {
                    print("do unwrap")
                }
                return result
                } }
        )
    }

    @objc func nextScreenBack(_ bbi: UIBarButtonItem) {
        self.container.router.execute(route: self.welcomeRouteSequence) { _ in }
    }
    
    let container: ApplicationContainerType
}
