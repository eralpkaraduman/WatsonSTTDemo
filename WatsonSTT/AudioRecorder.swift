//
//  AudioRecorder.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/16/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import AVFoundation

class AudioRecorder: NSObject {

    let recordInterval: TimeInterval = 2

    private (set) var  recording = false

    private let recorder: AVAudioRecorder

    override init() {

        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask, true
        ).first!

        let tempSoundFile = "temp.caf"
        let tempSoundPath = NSString(string: documentsPath).appendingPathComponent(tempSoundFile)
        let tempSoundURL = URL(fileURLWithPath: tempSoundPath)

        recorder = try! AVAudioRecorder(url: tempSoundURL, settings: [
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100
        ])

        super.init()

        recorder.delegate = self

    }

    func continueRecording() {
        recorder.record(forDuration: recordInterval)
    }

    func startRecording() {
        recording = true
        recorder.prepareToRecord()
        continueRecording()
    }

    func stopRecording() {
        guard recorder.isRecording else { return }
        recorder.stop()
    }

    func processRecordedSound() {



    }

}

extension AudioRecorder: AVAudioRecorderDelegate {

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {

    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

        processRecordedSound()

        if recording {
            continueRecording()
        }
    }

}
