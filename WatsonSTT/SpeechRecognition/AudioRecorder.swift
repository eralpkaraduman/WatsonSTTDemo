//
//  AudioRecorder.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/16/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

// boilerplate implementation based on:
// https://developer.apple.com/library/content/documentation/MusicAudio/Conceptual/AudioQueueProgrammingGuide/AQRecord/RecordingAudio.html#//apple_ref/doc/uid/TP40005343-CH4-SW1

import Foundation
import AVFoundation
import AudioToolbox

protocol AudioRecorderDelegate: class {
    func audioRecorder(_ recorder: AudioRecorder, didRecordData data: Data)
}

class AudioRecorder: NSObject {

    private(set) var format = AudioStreamBasicDescription()
    let session = AVAudioSession.sharedInstance()
    private var queue: AudioQueueRef? = nil
    private(set) var recording = false

    weak var delegate: AudioRecorderDelegate?

    override init() {

        var formatFlags = AudioFormatFlags()
        formatFlags |= kLinearPCMFormatFlagIsSignedInteger
        formatFlags |= kLinearPCMFormatFlagIsPacked
        format = AudioStreamBasicDescription(
            mSampleRate: 22050.0,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: formatFlags,
            mBytesPerPacket: UInt32(1*MemoryLayout<Int16>.stride),
            mFramesPerPacket: 1,
            mBytesPerFrame: UInt32(1*MemoryLayout<Int16>.stride),
            mChannelsPerFrame: 1,
            mBitsPerChannel: 16,
            mReserved: 0
        )
    }

    internal var audioInputCallback: AudioQueueInputCallback = {
        recorderPointer, queue, bufferRef, startTimeRef, numPackets, _ in

        guard let recorderPointer = recorderPointer else { return }
        let recorder = Unmanaged<AudioRecorder>.fromOpaque(recorderPointer).takeUnretainedValue()

        let buffer = bufferRef.pointee
        let startTime = startTimeRef.pointee

        var numPackets = numPackets
        if numPackets == 0 && recorder.format.mBytesPerPacket != 0 {
            numPackets = buffer.mAudioDataByteSize / recorder.format.mBytesPerPacket
        }

        let pcm = Data(bytes: buffer.mAudioData, count: Int(buffer.mAudioDataByteSize))
        if pcm.count > 0 {
            recorder.delegate?.audioRecorder(recorder, didRecordData: pcm)
        }

        guard recorder.recording else { return }

        if let queue = recorder.queue {
            AudioQueueEnqueueBuffer(queue, bufferRef, 0, nil)
        }
    }

    private func prepare() {

        let userDataPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        AudioQueueNewInput(
            &format,
            audioInputCallback,
            userDataPointer,
            nil,
            nil,
            0,
            &queue
        )

        guard let queue = queue else { return }

        var formatSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.stride)
        AudioQueueGetProperty(queue, kAudioQueueProperty_StreamDescription, &format, &formatSize)

        let numBuffers = 5
        let bufferSize = deriveBufferSize(seconds: 0.5)
        for _ in 0..<numBuffers {
            let bufferRef = UnsafeMutablePointer<AudioQueueBufferRef?>.allocate(capacity: 1)
            AudioQueueAllocateBuffer(queue, bufferSize, bufferRef)
            if let buffer = bufferRef.pointee {
                AudioQueueEnqueueBuffer(queue, buffer, 0, nil)
            }
        }
    }

    func startRecording() throws {

        try? session.setCategory(
            AVAudioSessionCategoryPlayAndRecord,
            with: AVAudioSessionCategoryOptions.defaultToSpeaker
        )

        try? session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)

        guard !recording else { return }
        self.prepare()
        self.recording = true
        guard let queue = queue else { return }
        AudioQueueStart(queue, nil)
    }

    func stopRecording() throws {
        guard recording else { return }
        guard let queue = queue else { return }
        recording = false

        AudioQueueStop(queue, true)
        AudioQueueDispose(queue, false)
    }

    private func deriveBufferSize(seconds: Float64) -> UInt32 {
        guard let queue = queue else { return 0 }
        let maxBufferSize = UInt32(0x50000)
        var maxPacketSize = format.mBytesPerPacket

        if maxPacketSize == 0 {

            var maxVBRPacketSize = UInt32(MemoryLayout<UInt32>.stride)
            AudioQueueGetProperty(
                queue,
                kAudioQueueProperty_MaximumOutputPacketSize,
                &maxPacketSize,
                &maxVBRPacketSize
            )
        }

        let numBytesForTime = UInt32(format.mSampleRate * Float64(maxPacketSize) * seconds)
        let bufferSize = (numBytesForTime < maxBufferSize ? numBytesForTime : maxBufferSize)
        return bufferSize
    }
}
