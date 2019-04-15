//
//  IVGACApplicationDelegate.swift
//  IVGAppContainer
//
//  Base implementation of UIApplicationDelegate to ensure it implements the full ApplicationContainerType pattern
//
//  Created by Douglas Sjoquist on 3/20/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

open class IVGACApplicationDelegate<T: ApplicationContainerType> : UIResponder, UIApplicationDelegate {

    // MARK: - methods to override

    /// override for testing or if a subclass is desired
    public lazy var container: T = self.createApplicationContainer(withWindow: self.window)

    public func createApplicationContainer(withWindow window: UIWindow?) -> T {
        return T(window: window)
    }

    open func configure(application: UIApplication, applicationContainer container: T) {
        fatalError("You must override this method to configure the application container")
    }

    // MARK: - standard UIApplicationDelegate methods

    public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        configure(application: application, applicationContainer: container)
        container.executeStartupAction()
        
        return container.willFinishLaunching()
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let result = container.didFinishLaunching()
        if result {
            window?.makeKeyAndVisible()
        }
        return result
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        container.didBecomeActive()
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        container.willResignActive()
    }

    public func applicationWillTerminate(_ application: UIApplication) {
        container.willTerminate()
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        container.didEnterBackground()
    }

    public func applicationWillEnterForeground(_ application: UIApplication) {
        container.willEnterForeground()
    }

    // MARK: - private variables

    public var window: UIWindow?
}
