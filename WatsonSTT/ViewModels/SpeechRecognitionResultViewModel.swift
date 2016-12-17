//
//  SpeechRecognitionResultViewModel.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/18/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import Foundation

class SpeechRecognitionResultViewModel {

    let result: SpeechRecognitionResult

    init(result: SpeechRecognitionResult) {
        self.result = result
    }

    var transcriptText: String {

        return result.alternatives.flatMap({
            $0
        }).sorted(by: { first, second -> Bool in

            let firstConfidence = NSString(string: first.confidence ?? "").floatValue
            let secondConfidence = NSString(string: second.confidence ?? "").floatValue

            return firstConfidence > secondConfidence

        }).first?.transcript ?? ""
    }

}
