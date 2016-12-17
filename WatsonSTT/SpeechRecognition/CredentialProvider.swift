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
        let tokenURLStr = CredentialProvider.infoValueForKey("BLUEMIX_WATSON_STT_TOKEN_URL"),
        let uname = CredentialProvider.infoValueForKey("BLUEMIX_WATSON_STT_USERNAME"),
        let passwd = CredentialProvider.infoValueForKey("BLUEMIX_WATSON_STT_PASSWORD"),
        let streamURLStr = CredentialProvider.infoValueForKey("BLUEMIX_WATSON_STT_STREAM_URL")
        else { return nil }

        self.tokenURLString = tokenURLStr
        self.streamURLString = streamURLStr
        self.password = passwd
        self.username = uname
    }

    static func infoValueForKey(_ key: String) -> String? {
        return Bundle.main.infoDictionary?[key] as? String
    }
}
