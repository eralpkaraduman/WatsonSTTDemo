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

        speechRecognitionClient.delegate = self
        speechRecognitionClient.start()

    }
}

extension SpeechToTextViewController: SpeechRecognitionClientDelegate {

    func speechRecognitionClientBeganAuthenticating(
        speechRecognitionClient: SpeechRecognitionClient) {

    }

    func speechRecognitionClientCompleteAuthenticating(
        speechRecognitionClient: SpeechRecognitionClient,
        success: Bool) {

        if success {
            speechRecognitionClient.start()
        }
        
    }

    func speechRecognitionClientStartedStreaming(
        speechRecognitionClient: SpeechRecognitionClient) {

    }

    func speechRecognitionClientEndedStreaming(
        speechRecognitionClient: SpeechRecognitionClient) {

    }

}
