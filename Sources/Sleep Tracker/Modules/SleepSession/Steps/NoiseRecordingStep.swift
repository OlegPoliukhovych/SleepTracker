//
//  NoiseRecordingStep.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/16/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

final class NoiseRecordingStep: SessionStep {

    var audioItem: AudioItem?
    
    init() {
        audioItem = AudioItem(mode: .record(destination: FileManager.default.recordingsFolderUrl))
    }

    // MARK: PlayerViewModelDataProvidable

    var style: PlayerViewControlsStyle {
        .recording
    }

    var title: AnyPublisher<String, Never> {
        Just("noise recording")
            .eraseToAnyPublisher()
    }
}
