//
//  SpeechRecognitionAlternative.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/17/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import Foundation

struct SpeechRecognitionAlternative {

    let confidence: String?
    let transcript: String?

    init?(dictionary: [String : Any]) {

        confidence = dictionary["confidence"] as? String
        transcript = dictionary["transcript"] as? String
    }
}
