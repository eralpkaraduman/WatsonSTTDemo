//
//  RecorderViewController.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/17/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import UIKit
import SVProgressHUD

class SpeechToTextViewController: UIViewController {

    var speechRecognitionClient: SpeechRecognitionClient!

    @IBOutlet weak var transcriptLabel: UILabel!
    @IBOutlet weak var recordButton: RecordButton!

    var resultViewModel: SpeechRecognitionResultViewModel? {
        didSet {
            transcriptLabel.text = resultViewModel?.transcriptText ?? ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        recordButton.recordState = .idle
        resultViewModel = nil

        guard let credentials = CredentialProvider() else {
            fatalError("couldn't load credentials")
        }

        speechRecognitionClient = SpeechRecognitionClient(credentials: credentials)
        speechRecognitionClient.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        speechRecognitionClient.prepare()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func recordButtonDidTriggerTap() {

        guard let client = speechRecognitionClient else { return }

        switch client.status {
        case .ready, .idle:
            speechRecognitionClient.start()
        case .recognizing:
            speechRecognitionClient.stop()
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

            SVProgressHUD.show(withStatus: "Authenticating")

        case .connectingToSocket:

            SVProgressHUD.show(withStatus: "Connecting")

        case .ready:

            recordButton.recordState = .idle
            self.resultViewModel = nil
            SVProgressHUD.dismiss()

        case .recognizing:

            recordButton.recordState = .recording
        }
    }

    func speechRecognitionClient(
        speechRecognitionClient: SpeechRecognitionClient,
        didReceiveResult result: SpeechRecognitionResult) {

        self.resultViewModel = SpeechRecognitionResultViewModel(result: result)
    }

    func speechRecognitionClient(
        speechRecognitionClient: SpeechRecognitionClient,
        didFailWithError error: Any?) {

        SVProgressHUD.showError(withStatus: String(describing: error ?? "Unknown Error"))
    }
}
