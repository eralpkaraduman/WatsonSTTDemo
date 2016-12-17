//
//  SpeechRecognitionResult.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/17/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import Foundation

struct SpeechRecognitionResult {

    let alternatives: [SpeechRecognitionAlternative]
    let isFinal: Bool

    init(json: [String : Any]) {

        if let alts = json["alternatives"] as? [[String : Any]] {
            alternatives = alts.flatMap { SpeechRecognitionAlternative(dictionary: $0) }
        } else {
            alternatives = []
        }

        isFinal = json["final"] as? Bool ?? false
    }
}
