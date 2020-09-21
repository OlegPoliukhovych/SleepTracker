//
//  NoiseRecordingStep.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/16/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

final class NoiseRecordingStep: SessionStepBaseModel {

    override init() {
        super.init()
        audioItem = AudioItem(mode: .record(destination: FileManager.default.recordingsFolderUrl))
    }

    // MARK: PlayerViewModelDataProvidable

    override var style: PlayerViewControlsStyle {
        .recording
    }

    override var title: AnyPublisher<String, Never> {
        Just("noise recording")
            .eraseToAnyPublisher()
    }
}
