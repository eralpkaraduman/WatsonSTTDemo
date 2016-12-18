//
//  PermissionRequestViewController.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/16/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import UIKit
import PermissionScope

protocol PermissionRequestViewControllerDelegate: class {
    func permissionRequestViewControllerDidFinish(controller: PermissionRequestViewController)
}

class PermissionRequestViewController: UIViewController {

    weak var delegate: PermissionRequestViewControllerDelegate?
    let permissionScope = PermissionScope()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        permissionScope.viewControllerForAlerts = self

        permissionScope.onAuthChange = { finished, permissions in
            if finished {
                self.checkPermissions()
            }
        }

        let setupButton = UIButton(type: .roundedRect)
        setupButton.setTitle("Tap To Setup Microphone Permission", for: .normal)
        view.addSubview(setupButton)
        setupButton.translatesAutoresizingMaskIntoConstraints = false
        setupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        setupButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        setupButton.addTarget(
            self,
            action: #selector(setupButtonDidTriggerTap),
            for: .touchUpInside
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        checkPermissions()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func setupButtonDidTriggerTap() {

        checkPermissions()
    }

    func checkPermissions() {

        if case .authorized = permissionScope.statusMicrophone() {

            delegate?.permissionRequestViewControllerDidFinish(controller: self)

        } else {

            permissionScope.requestMicrophone()
        }
    }
}
