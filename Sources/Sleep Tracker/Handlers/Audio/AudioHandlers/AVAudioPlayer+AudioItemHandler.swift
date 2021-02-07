//
//  AVAudioPlayer+AudioItemHandler.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/10/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import AVFoundation

extension AVAudioPlayer: AudioItemHandler {

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
