//
//  AppDelegate.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/16/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
        -> Bool {

        configureHockeyapp()

        window = UIWindow()
        guard let window = window else { fatalError() }

        appCoordinator = AppCoordinator(window: window)
        appCoordinator.start()
        window.makeKeyAndVisible()

        return true
    }

    func configureHockeyapp() {

        BITHockeyManager.shared().configure(
            withIdentifier: "0d78f9aa23dd4c8cb7acb2655d7253e0"
        )
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
    }
}
