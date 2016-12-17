//
//  SpeechRecognitionClient.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/17/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import Foundation

protocol SpeechRecognitionClientDelegate: class {

    func speechRecognitionClientBecameReady(
        speechRecognitionClient: SpeechRecognitionClient
    )

    func speechRecognitionClientBecameIdle(
        speechRecognitionClient: SpeechRecognitionClient
    )
}

class SpeechRecognitionClient {

    private var token: String? = nil
    private var authenticationTask: URLSessionDataTask? = nil

    let audioRecorder = AudioRecorder()
    let socketClient = SocketClient()
    private let credendials: CredentialProvider

    private (set) var started = false

    weak var delegate: SpeechRecognitionClientDelegate? = nil

    var recording: Bool {
        return audioRecorder.recording
    }

    init?() {

        if let credentialProvider = CredentialProvider() {
            self.credendials = credentialProvider
        } else {
            return nil
        }
        audioRecorder.delegate = self
        socketClient.delegate = self
    }

    static func valueForInfoDictionaryKey(_ key: String) -> String? {
        return Bundle.main.infoDictionary?[key] as? String
    }

    func prepare() {

        guard let token = token else {
            authenticate()
            return
        }

        guard socketClient.connected else {
            socketClient.connect(streamURLString: credendials.streamURLString, token: token)
            return
        }

        if !audioRecorder.recording {

            do {
                try audioRecorder.startRecording()
            } catch {
                self.delegate?.speechRecognitionClientBecameIdle(speechRecognitionClient: self)
                return
            }
        }

        self.delegate?.speechRecognitionClientBecameReady(speechRecognitionClient: self)
    }

    func start() {

        let sampleRate = Int(audioRecorder.format.mSampleRate)

        let contentType = [
            "audio/l16",
            "rate=" + String(sampleRate)
        ].joined(separator: ";")

        socketClient.writeJSON([
            "action": "start",
            "content-type": contentType
        ])

        started = true
    }

    private func authenticate() {

        let authenticator = HTTPBasicAuthenticator(
            tokenURLString: credendials.tokenURLString,
            username: credendials.username,
            password: credendials.password,
            queryParams: ["url": credendials.streamURLString]
        )

        authenticationTask?.cancel()

        authenticationTask = authenticator?.authenticationRequestTask(
            withCompletionHandler: { result in

                switch result {
                case .Success(let token):

                    self.token = token
                    self.prepare()

                case .Failure:

                    self.delegate?.speechRecognitionClientBecameIdle(speechRecognitionClient: self)

                }
        })

        authenticationTask?.resume()
    }

    func serverStartedListening() {
        started = true
    }

}

extension SpeechRecognitionClient: AudioRecorderDelegate {

    func audioRecorder(_ recorder: AudioRecorder, didRecordData data: Data) {
        if socketClient.connected && started {
            socketClient.writeData(data)
        }
    }
}

extension SpeechRecognitionClient :SocketClientDelegate {

    func socketClientDidConnect(socketClient: SocketClient) {
        self.prepare()
    }

    func socketClientDidDisconnect(socketClient: SocketClient) {

    }

    func socketClient(_ socketClient: SocketClient, didReceiveJsonObject jsonObject: JsonObject) {

        print(jsonObject)

        if let state = jsonObject["state"] as? String, state == "listening" {
            self.serverStartedListening()
        }
    }
}
