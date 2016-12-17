//
//  SpeechRecognitionClient.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/17/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import Foundation

protocol SpeechRecognitionClientDelegate: class {

    func speechRecognitionClient (
        speechRecognitionClient: SpeechRecognitionClient,
        didSwitchToStatus status: SpeechRecognitionClient.Status
    )

    func speechRecognitionClient (
        speechRecognitionClient: SpeechRecognitionClient,
        didReceiveResult result: SpeechRecognitionResult
    )
}

class SpeechRecognitionClient {

    enum Status {
        case idle
        case auth
        case connectingToSocket
        case ready
        case recognizing
    }

    private var token: String? = nil
    private var authenticationTask: URLSessionDataTask? = nil

    let audioRecorder = AudioRecorder()
    let socketClient = SocketClient()
    private let credendials: CredentialProvider

    private (set) var status: Status {
        didSet {
            self.delegate?.speechRecognitionClient(
                speechRecognitionClient: self,
                didSwitchToStatus: self.status
            )
        }
    }

    weak var delegate: SpeechRecognitionClientDelegate? = nil

    var recording: Bool {
        return audioRecorder.recording
    }

    init?() {

        status = .idle

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

        status = .idle

        try? audioRecorder.stopRecording()

        guard let token = token else {

            status = .auth
            authenticate()
            return
        }

        guard socketClient.connected else {

            status = .connectingToSocket
            socketClient.connect(streamURLString: credendials.streamURLString, token: token)
            return
        }

        status = .ready
    }

    func start() {

        let sampleRate = Int(audioRecorder.format.mSampleRate)

        let contentType = [
            "audio/l16",
            "rate=" + String(sampleRate),
        ].joined(separator: ";")

        socketClient.writeJSON([
            "action": "start",
            "content-type": contentType,
            "interim_results": true
        ])

        do {
            try audioRecorder.startRecording()
        } catch {
            status = .idle
            return
        }

        status = .recognizing
    }

    func stop() {

        try? audioRecorder.stopRecording()

        socketClient.writeJSON([
            "action": "stop"
        ])

        status = .idle
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

                    self.status = .idle

                }
        })

        authenticationTask?.resume()
    }

    func serverStartedListening() {

    }

    func serverDisconnected() {
        stop()
    }

}

extension SpeechRecognitionClient: AudioRecorderDelegate {

    func audioRecorder(_ recorder: AudioRecorder, didRecordData data: Data) {
        if socketClient.connected && status == .recognizing {
            //print("writing \(data.count) bytes of sound to socket")
            socketClient.writeData(data)
        }
    }
}

extension SpeechRecognitionClient :SocketClientDelegate {

    func socketClientDidConnect(socketClient: SocketClient) {
        self.prepare()
    }

    func socketClientDidDisconnect(socketClient: SocketClient) {
        self.serverDisconnected()
    }

    func socketClient(_ socketClient: SocketClient, didReceiveJsonObject jsonObject: JsonObject) {

        //print(jsonObject)

        if let state = jsonObject["state"] as? String, state == "listening" {
            self.serverStartedListening()
        }

        if let json = (jsonObject["results"] as? [[String : Any]])?.first {

            let result = SpeechRecognitionResult(json: json)

            delegate?.speechRecognitionClient(
                speechRecognitionClient: self,
                didReceiveResult: result
            )
        }

        //TODO: handle socket auth error, set client idle, reset token
    }
}
