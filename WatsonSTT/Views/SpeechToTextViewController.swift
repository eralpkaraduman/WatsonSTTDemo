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

    @IBOutlet weak var transcriptLabel: UILabel!
    @IBOutlet weak var recordButton: RecordButton!

    var resultViewModel: SpeechRecognitionResultViewModel? {
        didSet {
            transcriptLabel.text = resultViewModel?.transcriptText ?? ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        speechRecognitionClient?.delegate = self

        recordButton.recordState = .idle
        resultViewModel = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        speechRecognitionClient?.prepare()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func recordButtonDidTriggerTap() {

        guard let client = speechRecognitionClient else { return }

        switch client.status {
        case .ready, .idle:
            speechRecognitionClient?.start()
        case .recognizing:
            speechRecognitionClient?.stop()
        default:
            break
        }
    }
}

extension SpeechToTextViewController: SpeechRecognitionClientDelegate {

    func speechRecognitionClient(
        speechRecognitionClient: SpeechRecognitionClient,
        didSwitchToStatus status: SpeechRecognitionClient.Status) {

        switch status {
        case .idle:

            recordButton.recordState = .idle
        case .auth:

            print("authenticating...")
            //ButtonState.preparing.configure(button: recordButton)

        case .connectingToSocket:

            print("connecting to socket...")
            //ButtonState.preparing.configure(button: recordButton)

        case .ready:

            recordButton.recordState = .idle

        case .recognizing:

            recordButton.recordState = .recording
        }
    }

    func speechRecognitionClient(
        speechRecognitionClient: SpeechRecognitionClient,
        didReceiveResult result: SpeechRecognitionResult) {

        self.resultViewModel = SpeechRecognitionResultViewModel(result: result)
    }
}
