//
//  RecorderViewController.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/17/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import UIKit

class SpeechToTextViewController: UIViewController {

    let audioRecorder = AudioRecorder()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        audioRecorder.delegate = self

        try? audioRecorder.startRecording()
    }
}

extension SpeechToTextViewController: AudioRecorderDelegate {

    func audioRecorder(_ recorder: AudioRecorder, didRecordData data: Data) {
        print(data.count)
    }
}
