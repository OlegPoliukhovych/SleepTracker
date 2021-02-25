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
    var onStart: AnyPublisher<Date, Never> {
        audioItem?
            .statePublisher
            .filter { $0 == .running }
            .first()
            .flatMap { _ in Just(Date()) }
            .eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    init(recordingUrl: URL, timeout: Date?) {

        audioItem = AudioItem(mode: .record(destination: recordingUrl))

        guard let date = timeout else {
            return
        }

        // setup timer on actual recording start
        let timer = audioItem?.statePublisher
            .filter { $0 == .running }
            .map { _ in date.timeIntervalSinceNow }
            .flatMap { Timer.TimerPublisher(interval: $0, runLoop: .current, mode: .default).autoconnect() }
            .eraseToAnyPublisher()
            .share()
            .sink { [weak self] _ in
                self?.skipStep()
            }

        // cancel timer if step was skipped
        audioItem?.statePublisher
            .filter { $0 == .stopped }
            .sink { _ in timer?.cancel() }
            .store(in: &cancellables)
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
