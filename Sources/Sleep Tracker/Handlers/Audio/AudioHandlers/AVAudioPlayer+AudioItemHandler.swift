//
//  AVAudioPlayer+AudioItemHandler.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/10/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import AVFoundation

extension AVAudioPlayer: AudioItemHandler {

    convenience init(soundUrl: URL, startTime: Date?) throws {
        try self.init(contentsOf: soundUrl)

        guard let startDate = startTime else {
            return
        }
        play(atTime: deviceCurrentTime + startDate.timeIntervalSinceNow)
    }


    func prepare() {
        numberOfLoops = -1
    }

    func run() {
        play()
    }

    func finish() {
        stop()
    }
}
