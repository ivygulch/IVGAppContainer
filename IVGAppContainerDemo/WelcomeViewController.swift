//
//  WelcomeViewController.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/21/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

class WelcomeViewController : UIViewController {

    var nextAction: ((Void) -> Void)?

    @IBAction func nextAction(_ button: UIButton) {
        print("nextAction")
        nextAction?()
    }

}
