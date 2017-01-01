//
//  LazyViewController.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/29/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

public class LazyViewController : UIViewController {

    public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, loadSegment:@escaping (Void) -> (UIViewController?)) {
        self.loadSegment = loadSegment
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if let loadSegment = loadSegment, let childViewController = loadSegment() {
            addChildViewController(childViewController)
            childViewController.view.frame =
                view.bounds
            view.addSubview(childViewController.view)
            childViewController.didMove(toParentViewController: self)
        }
    }

    public lazy var childViewController: UIViewController? = {
        return self.childViewControllers.first
    }()

    fileprivate var loadSegment:((Void) -> (UIViewController?))?

}
