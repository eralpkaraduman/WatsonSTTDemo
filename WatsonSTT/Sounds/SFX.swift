//
//  SFX.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/18/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import AVFoundation

enum SFX: String {

    case up = "up.wav"
    case down = "down.wav"

    static var all: [SFX] { return [
        up,
        down
    ]}

    static private var preloadedPlayers = [SFXPlayer]()

    var fileName: String {
        return self.rawValue
    }

    var url: URL? {

        let fileParts = self.fileName.characters.split(separator: ".").map(String.init)
        return Bundle.main.url(forResource: fileParts[0], withExtension: fileParts[1])
    }

    func createPlayer() -> SFXPlayer {

        guard
        let url = url,
        let player = try? AVAudioPlayer(contentsOf: url)
        else { fatalError() }

        player.numberOfLoops = 0 // -1 loop
        player.prepareToPlay()

        return SFXPlayer(sfx: self, player: player)
    }

    func play() {

        guard let player = SFX.preloadedPlayers.filter({
            $0.sfx == self
        }).first else {
            return
        }

        if player.playing {
            player.stop()
        }

        player.play()
    }

    static func preloadAll() {

        preloadedPlayers.removeAll()

        for sfx in all {
            let preloadedPlayer = sfx.createPlayer()
            preloadedPlayers.append(preloadedPlayer)
        }
    }
}

class SFXPlayer: NSObject {
    let sfx: SFX
    let player: AVAudioPlayer

    init(sfx: SFX, player: AVAudioPlayer) {
        self.sfx = sfx
        self.player = player
        super.init()
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func stop() {
        player.stop()
    }

    var playing: Bool {
        return player.isPlaying
    }

    func destroy() {
        player.pause()
        player.stop()
    }
}
