//
//  AudioItemPlayer.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/10/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import AVFoundation

struct AudioItemPlayer: AudioItemHandler {

    private let audioPlayer: AVAudioPlayer?

    init(soundUrl: URL, startTime: Date?) {
        self.init(soundUrl: soundUrl)
        guard let deviceCurrentTime = audioPlayer?.deviceCurrentTime,
            let startDate = startTime else {
                return
        }
        audioPlayer?.play(atTime: deviceCurrentTime + startDate.timeIntervalSinceNow)
    }

    init(soundUrl: URL) {
        audioPlayer = try? AVAudioPlayer(contentsOf: soundUrl)
        audioPlayer?.numberOfLoops = -1
    }

    func run() {
        audioPlayer?.play()
    }

    func pause() {
        audioPlayer?.pause()
    }

    func finish() {
        audioPlayer?.stop()
    }
}
