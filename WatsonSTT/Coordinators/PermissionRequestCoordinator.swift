//
//  PermissionRequestCoordinator.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/16/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import UIKit

protocol PermissionRequestCoordinatorDelegate: class {
    func permissionRequestCoordinatorDidFinish(coordinator: PermissionRequestCoordinator)
}

class PermissionRequestCoordinator: Coordinator {

    weak var delegate: PermissionRequestCoordinatorDelegate?
    let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let vc = PermissionRequestViewController()
        vc.delegate = self
        window.rootViewController = vc
    }
}

extension PermissionRequestCoordinator: PermissionRequestViewControllerDelegate {

    func permissionRequestViewControllerDidFinish(controller: PermissionRequestViewController) {

        delegate?.permissionRequestCoordinatorDidFinish(coordinator: self)
    }
}
