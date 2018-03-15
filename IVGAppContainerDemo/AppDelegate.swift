//
//  AppDelegate.swift
//  IVGAppContainerDemo
//
//  Created by Douglas Sjoquist on 3/19/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import IVGAppContainer

@UIApplicationMain
class AppDelegate: IVGACApplicationDelegate<ApplicationContainer> {

    override func configure(applicationContainer container: ApplicationContainer) {
        let appCoordinator = DemoAppCoordinator(container: container)
        container.addCoordinator(appCoordinator, forProtocol: DemoAppCoordinatorType.self)
        container.startupAction = {
            router.execute(route: appCoordinator.welcomeRouteSequence) { _ in }
        }
    }

}
