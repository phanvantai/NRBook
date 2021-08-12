//
//  AppDelegate.swift
//  NRBook
//
//  Created by Tai Phan Van on 12/08/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootViewController: UINavigationController!
    lazy var mainViewController = NRLibraryVC()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupVC()
        
        return true
    }

}

extension AppDelegate {
    func setupVC() {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        mainViewController.view.backgroundColor = .white
        rootViewController = UINavigationController.init(rootViewController: mainViewController)
        rootViewController.view.backgroundColor = .white
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
}
