//
//  SpeechRecognitionClient.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/17/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import Foundation

protocol SpeechRecognitionClientDelegate: class {

    func speechRecognitionClientBeganAuthenticating(
        speechRecognitionClient: SpeechRecognitionClient
    )

    func speechRecognitionClientCompleteAuthenticating(
        speechRecognitionClient: SpeechRecognitionClient, success: Bool
    )

    func speechRecognitionClientStartedStreaming(
        speechRecognitionClient: SpeechRecognitionClient
    )

    func speechRecognitionClientEndedStreaming(
        speechRecognitionClient: SpeechRecognitionClient
    )
}

class SpeechRecognitionClient {

    private var token: String? = nil
    private let audioRecorder = AudioRecorder()
    private var authenticationTask: URLSessionDataTask? = nil

    let urlSession: URLSession

    weak var delegate: SpeechRecognitionClientDelegate? = nil

    var authenticated: Bool {
        return !(token?.isEmpty ?? true)
    }

    var recording: Bool {
        return audioRecorder.recording
    }

    init() {
        urlSession = URLSession(configuration: URLSessionConfiguration.default)
        audioRecorder.delegate = self
    }

    func valueForInfoDictionaryKey(_ key: String) -> String? {
        return Bundle.main.infoDictionary?[key] as? String
    }

    func start() {

        guard authenticated else {
            authenticate()
            return
        }

        // start recording
    }

    private func authenticate() {
        delegate?.speechRecognitionClientBeganAuthenticating(speechRecognitionClient: self)

        guard
        let tokenURLString = valueForInfoDictionaryKey("BLUEMIX_WATSON_STT_TOKEN_URL"),
        let username = valueForInfoDictionaryKey("BLUEMIX_WATSON_STT_USERNAME"),
        let password = valueForInfoDictionaryKey("BLUEMIX_WATSON_STT_PASSWORD"),
        let streamURLString = valueForInfoDictionaryKey("BLUEMIX_WATSON_STT_STREAM_URL")
        else { return }

        let authenticator = HTTPBasicAuthenticator(
            tokenURLString: tokenURLString,
            username: username,
            password: password,
            queryParams: ["url": streamURLString]
        )

        authenticationTask?.cancel()

        authenticationTask = authenticator?.authenticationRequestTask(
            withCompletionHandler: { result in

                switch result {
                case .Success(let token):

                    self.token = token

                    self.delegate?.speechRecognitionClientCompleteAuthenticating(
                        speechRecognitionClient: self,
                        success: true
                    )

                case .Failure:

                    self.delegate?.speechRecognitionClientCompleteAuthenticating(
                        speechRecognitionClient: self,
                        success: false
                    )
                } 
        })
        authenticationTask?.resume()
    }

}

extension SpeechRecognitionClient: AudioRecorderDelegate {

    func audioRecorder(_ recorder: AudioRecorder, didRecordData data: Data) {
        print(data.count)
    }
}
