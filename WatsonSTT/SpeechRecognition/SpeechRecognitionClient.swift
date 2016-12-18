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
        didSwitchToStatus status: SpeechRecognitionClient.Status,
        fromStatus previousStatus: SpeechRecognitionClient.Status
    )

    func speechRecognitionClient (
        speechRecognitionClient: SpeechRecognitionClient,
        didReceiveResult result: SpeechRecognitionResult
    )

    func speechRecognitionClient (
        speechRecognitionClient: SpeechRecognitionClient,
        didFailWithError error: Any?
    )
}

class SpeechRecognitionClient {

    enum RecognitionModel: String {
        case english = "en-US_BroadbandModel"
        case mandarin = "zh-CN_BroadbandModel"
        case french = "fr-FR_BroadbandModel"
        case spanish = "es-ES_BroadbandModel"
    }

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
    private let credentials: CredentialProvider

    private var previousStatus: Status = .idle

    private (set) var status: Status {

        willSet {
            self.previousStatus = self.status
        }

        didSet {
            self.delegate?.speechRecognitionClient(
                speechRecognitionClient: self,
                didSwitchToStatus: self.status,
                fromStatus: self.previousStatus
            )
        }
    }

    var recognitionModel: RecognitionModel = .english {

        didSet {

            if status == .recognizing {
                stop()
            }

            socketClient.disconnect()
        }
    }

    weak var delegate: SpeechRecognitionClientDelegate? = nil

    var recording: Bool {
        return audioRecorder.recording
    }

    init(credentials: CredentialProvider) {

        self.credentials = credentials
        status = .idle
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
            socketClient.connect(
                streamURLString: credentials.streamURLString,
                token: token,
                model: recognitionModel
            )
            return
        }

        status = .ready
    }

    func start() {

        prepare()

        guard socketClient.connected else { return }

        let sampleRate = Int(audioRecorder.format.mSampleRate)

        let contentType = [
            "audio/l16",
            "rate=" + String(sampleRate)
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
            tokenURLString: credentials.tokenURLString,
            username: credentials.username,
            password: credentials.password,
            queryParams: ["url": credentials.streamURLString]
        )

        authenticationTask?.cancel()

        authenticationTask = authenticator?.authenticationRequestTask(
            withCompletionHandler: { result in

                switch result {
                case .Success(let token):

                    self.token = token
                    self.prepare()

                case .Failure(let error):

                    self.token = nil
                    self.status = .idle

                    print("received auth error \(error)")

                    self.delegate?.speechRecognitionClient(
                        speechRecognitionClient: self,
                        didFailWithError: error
                    )
                }
        })

        authenticationTask?.resume()
    }

    func serverStartedListening() {

    }

    func serverDisconnected() {
        stop()
    }

    func receivedFinalResult() {
        status = .idle
    }
}

extension SpeechRecognitionClient: AudioRecorderDelegate {

    func audioRecorder(_ recorder: AudioRecorder, didRecordData data: Data) {
        if socketClient.connected && status == .recognizing {
            socketClient.writeData(data)
        }
    }
}

extension SpeechRecognitionClient :SocketClientDelegate {

    func socketClientDidConnect(socketClient: SocketClient) {
        self.prepare()
    }

    func socketClientDidDisconnect(socketClient: SocketClient, error: NSError?) {

        if let code = error?.code, let description = error?.localizedDescription {
            print("disconnected with error: \(code) \(description)")

            delegate?.speechRecognitionClient(
                speechRecognitionClient: self,
                didFailWithError: error
            )
        }

        self.serverDisconnected()
    }

    func socketClient(_ socketClient: SocketClient, didReceiveJsonObject jsonObject: JsonObject) {

        if let state = jsonObject["state"] as? String, state == "listening" {
            self.serverStartedListening()
        }

        if let errorMessage = jsonObject["error"] as? String {
            print("received socket error: \(errorMessage)")

            delegate?.speechRecognitionClient(
                speechRecognitionClient: self,
                didFailWithError: errorMessage
            )
        }

        if let json = (jsonObject["results"] as? [[String : Any]])?.first {

            let result = SpeechRecognitionResult(json: json)

            delegate?.speechRecognitionClient(
                speechRecognitionClient: self,
                didReceiveResult: result
            )

            if result.isFinal {
                receivedFinalResult()
            }

            let transcript = result.alternatives.first?.transcript ?? ""
            print("received transcript: \(transcript)")
        }
    }
}
