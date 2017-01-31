//
//  ViewControllerLoader.swift
//  IVGAppContainer
//
//  Created by Douglas Sjoquist on 3/29/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit

protocol ViewControllerLoaderType {
    func viewController<T: UIViewController>(forStoryboardName name: String, viewControllerType: T.Type, viewControllerID: String?) -> T?
}

extension ViewControllerLoaderType {

    func viewController<T: UIViewController>(forStoryboardName name: String, viewControllerType: T.Type) -> T? {
        return viewController(forStoryboardName: name, viewControllerType: viewControllerType, viewControllerID: nil)
    }

}

class ViewControllerLoader : ViewControllerLoaderType{

    func viewController<T: UIViewController>(forStoryboardName name: String, viewControllerType: T.Type, viewControllerID: String?) -> T? {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let useViewControllerID = viewControllerID ?? String(describing: viewControllerType)
        return storyboard.instantiateViewController(withIdentifier: useViewControllerID) as? T
    }
    
}
