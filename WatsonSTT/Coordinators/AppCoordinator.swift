//
//  AppCoordinator.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/16/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import UIKit
import PermissionScope

class AppCoordinator: Coordinator {

    enum CoordinatorKey: String {
        case permissionRequest
        case speechToText
    }

    var window: UIWindow
    var coordinators = [CoordinatorKey : Coordinator]()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {

        if case .authorized = PermissionScope().statusMicrophone() {
            showRecorderScreen()
        } else {
            showRequestPermissionScreen()
        }

    }

    func showRequestPermissionScreen() {
        let coordinator = PermissionRequestCoordinator(window: window)
        coordinators[.permissionRequest] = coordinator
        coordinator.delegate = self
        coordinator.start()
    }

    func showRecorderScreen() {
        let coordinator = SpeechToTextCoordinator(window: window)
        coordinators[.speechToText] = coordinator
        coordinator.delegate = self
        coordinator.start()
    }

}

extension AppCoordinator: PermissionRequestCoordinatorDelegate {

    func permissionRequestCoordinatorDidFinish(coordinator: PermissionRequestCoordinator) {
        coordinators[.permissionRequest] = nil
        showRecorderScreen()
    }
}

extension AppCoordinator: SpeechToTextCoordinatorDelegate {

    func speechToTextCoordinatorDidFinish(coordinator: SpeechToTextCoordinator) {
        coordinators[.speechToText] = nil

    }
}
