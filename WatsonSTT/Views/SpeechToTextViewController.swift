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
    let recordButton = UIButton(type: .system)

    enum ButtonState {
        case recording
        case idle

        var title: String {
            switch self {
            case .idle: return "Start Recording"
            case .recording: return "Stop Recording"
            }
        }

        var color: UIColor {
            switch self {
            case .idle: return .gray
            case .recording: return .red
            }
        }

        func configure(button: UIButton) {
            button.setTitle(title, for: .normal)
            button.setTitleColor(color, for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        ButtonState.idle.configure(button: recordButton)

        recordButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recordButton)
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        recordButton.addTarget(
            self,
            action: #selector(recordButtonDidTriggerTap),
            for: .touchUpInside
        )

        speechRecognitionClient?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        speechRecognitionClient?.prepare()
    }

    func recordButtonDidTriggerTap() {

        guard let client = speechRecognitionClient else { return }

        switch client.status {
        case .ready:
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
            print("idle")
            ButtonState.idle.configure(button: recordButton)
        case .auth:
            print("auth")
            ButtonState.idle.configure(button: recordButton)
        case .connectingToSocket:
            print("socket")
            ButtonState.idle.configure(button: recordButton)
        case .ready:
            print("ready")
            ButtonState.idle.configure(button: recordButton)
        case .recognizing:
            print("recognizing")
            ButtonState.recording.configure(button: recordButton)
        }
    }

    func speechRecognitionClient(
        speechRecognitionClient: SpeechRecognitionClient,
        didReceiveResult result: SpeechRecognitionResult) {

        let transcript = result.alternatives.first?.transcript ?? ""
        print("received transcript: \(transcript)")

    }

}
