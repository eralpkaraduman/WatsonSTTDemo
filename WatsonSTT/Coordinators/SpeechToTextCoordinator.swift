//
//  SpeechToTextCoordinator.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/17/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import UIKit

protocol SpeechToTextCoordinatorDelegate: class {
    func speechToTextCoordinatorDidFinish(coordinator: SpeechToTextCoordinator)
}

class SpeechToTextCoordinator: Coordinator {

    weak var delegate: SpeechToTextCoordinatorDelegate?
    let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {

        let sb = UIStoryboard.init(name: "SpeechToText", bundle: nil)
        if let vc = sb.instantiateInitialViewController() as? SpeechToTextViewController {
            window.rootViewController = vc
        }
    }
}
