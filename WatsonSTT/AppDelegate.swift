//
//  AppDelegate.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/16/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var audioRecorder: AudioRecorder!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let socketUrlString = Bundle.main.infoDictionary?["BLUEMIX_WATSON_STT_STREAM_URL"] as! String
        let username = Bundle.main.infoDictionary?["BLUEMIX_WATSON_STT_USERNAME"] as! String
        let password = Bundle.main.infoDictionary?["BLUEMIX_WATSON_STT_PASSWORD"] as! String
        print(socketUrlString)
        print(username)
        print(password)

        audioRecorder = AudioRecorder()
        audioRecorder.delegate = self
        try! audioRecorder.startRecording()

        return true
    }
}

extension AppDelegate: AudioRecorderDelegate {
    func audioRecorder(_ recorder: AudioRecorder, didRecordData data: Data) {
        print(data.count)
    }
}

