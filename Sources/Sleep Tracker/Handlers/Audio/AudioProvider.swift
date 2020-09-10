//
//  AudioProvider.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/7/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

final class AudioProvider {

    private var accentAudioItem: AudioItem?

    private var cancellables = Set<AnyCancellable>()

    init(audioItems: [AudioItem]) {
        configure(audioItems: audioItems)
    }

    private func configure(audioItems: [AudioItem]) {

        audioItems.forEach { audioItem in
            let itemHandler: AudioItemHandler
            switch audioItem.mode {
            case let .playback(fileUrl: url, startTime: date):
                itemHandler = AudioItemPlayer(soundUrl: url, startTime: date)
            case .record(destination: let destination):
                itemHandler = AudioItemRecorder(destination: destination)
            }

            audioItem.statePublisher
                .sink { state in
                    switch state {
                    case .running:
                        itemHandler.run()
                    case .paused:
                        itemHandler.pause()
                    case .stopped:
                        itemHandler.finish()
                    }
                }
                .store(in: &cancellables)
        }
    }

    func setAccent(audioItem: AudioItem) {
        self.accentAudioItem = audioItem
    }
}
