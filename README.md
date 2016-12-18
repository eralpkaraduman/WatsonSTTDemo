IBM Watson Speech To Text API iOS Integration Demo
==================================================

Demo integration of IBM Watson using websocket API  
Built using swift 3  

### Created by:
Eralp Karaduman  
[eralpkaraduman.com](http://eralpkaraduman.com)


## Usage

Create a Watson Speech to Text service from Bluemix  
Enter your credentials to: `WatsonSTT/prod.xcconfig`

When it launches, wait for it to authenticate & connect to socket  
Tap the microphone button ( don't tap and hold )  
Start speaking when you hear the sound effect  
You should see the text update as you speak

- Tap the button when its **gray** to **start** recording 
- Tap the button when its **red** to **stop** recording
- When you stop speaking Watson automaticaly stops recognizing  

## Reviewing

- App is architectured around MVVM-C approach.  
- Best entry point for understanding the implementation would be: `ViewControllers/SpeechToTextViewController.swift`
- Speech recognition session is managed by: `SpeechRecognition/SpeechRecognitionClient.swift`
- UI implementation tracks the state by utilizing `SpeechRecognitionClientDelegate`
- `SpeechRecognition/AudioRecorder.swift` is responsible for recording the sound and outputing as PCM
- Recording logic is based on [Apple's Recording Audido Guide](https://developer.apple.com/library/content/documentation/MusicAudio/Conceptual/AudioQueueProgrammingGuide/AQRecord/RecordingAudio.html#//apple_ref/doc/uid/TP40005343-CH4-SW1)
- `SpeechRecognition/SocketClient.swift` is responsible for connecting to and keeping the socket session
- sends no-op action in every fixed (hardcoded) interval to keep the connection alive
- `speechRecognitionClient.recognitionModel = .mandarin` sets the language, defaults to english

## Known Issues

Due to being demo only, there are some issues exist;

- After app goes to background and turns back to foreground, socket may disconnect and app won't try to reconnect automaticaly.
  - You should see an error alert displaying the error response
  - Tap the gray button again
  - Wait for it to recconnect
  - You should still see the button in gray state
  - Tap again to start recognizing

- Doesn't store auth token locally, authenticates again at every launch
- Recognized english only, this setting is hardcoded
- Doesn't properly handle the offline state
