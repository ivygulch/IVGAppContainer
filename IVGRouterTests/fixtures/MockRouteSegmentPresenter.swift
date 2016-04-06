//
//  MockRouteSegmentPresenter.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/1/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

class MockRouteSegmentPresenter : TrackableTestClass, RouteSegmentPresenterType {

    init(presenterIdentifier: String, completionBlockArg: Bool) {
        self.presenterIdentifier = Identifier(name: presenterIdentifier)
        self.completionBlockArg = completionBlockArg
    }

    let presenterIdentifier: Identifier

    func presentViewController(presentedViewController : UIViewController, from presentingViewController: UIViewController?, withWindow window: UIWindow?, completion: (Bool) -> Void) {
        let from = presentingViewController?.description ?? "nil"
        let windowID = window == nil ? "nil" : "\(unsafeAddressOf(window!))"
        track("presentViewController", [presentedViewController.description,from,windowID])
        completion(completionBlockArg)
    }

    private let completionBlockArg: Bool
}
