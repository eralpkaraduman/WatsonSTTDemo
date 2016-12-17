//
//  RecorderViewController.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/17/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import UIKit

class SpeechToTextViewController: UIViewController {

    let speechRecognitionClient = SpeechRecognitionClient()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        speechRecognitionClient?.delegate = self
        speechRecognitionClient?.prepare()

    }
}

extension SpeechToTextViewController: SpeechRecognitionClientDelegate {

    func speechRecognitionClientBecameReady(speechRecognitionClient: SpeechRecognitionClient) {
        speechRecognitionClient.start()
    }

    func speechRecognitionClientBecameIdle(speechRecognitionClient: SpeechRecognitionClient) {

    }

}
