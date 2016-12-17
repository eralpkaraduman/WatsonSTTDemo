//
//  CredentialProvider.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/17/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import Foundation

class CredentialProvider {

    let tokenURLString: String
    let streamURLString: String
    let username: String
    let password: String

    init?() {

        guard
        let tokenURLString = CredentialProvider.valueForKey("BLUEMIX_WATSON_STT_TOKEN_URL"),
        let username = CredentialProvider.valueForKey("BLUEMIX_WATSON_STT_USERNAME"),
        let password = CredentialProvider.valueForKey("BLUEMIX_WATSON_STT_PASSWORD"),
        let streamURLString = CredentialProvider.valueForKey("BLUEMIX_WATSON_STT_STREAM_URL")
        else { return nil }

        self.tokenURLString = tokenURLString
        self.streamURLString = streamURLString
        self.password = password
        self.username = username

    }

    static func valueForKey(_ key: String) -> String? {
        return Bundle.main.infoDictionary?[key] as? String
    }

}
