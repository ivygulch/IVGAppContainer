//
//  WrapperViewController.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 4/8/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

class WrapperViewController : UIViewController {

    var unwrapAction: ((Void) -> Void)?

    @IBAction func unwrapAction(_ button: UIButton) {
        print("unwrapAction")
        unwrapAction?()
    }
    
}
