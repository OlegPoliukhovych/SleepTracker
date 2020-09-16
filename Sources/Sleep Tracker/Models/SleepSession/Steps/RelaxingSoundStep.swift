//
//  RelaxingSoundStep.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 8/30/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

final class RelaxingSoundStep: SessionStepBaseModel {

    private var timer: Cancellable?
    private var durationSubject: CurrentValueSubject<TimeInterval, Never>

    init(duration: TimeInterval) {
        durationSubject = .init(duration)
        super.init()

        if let path = Bundle.main.path(forResource: "nature.m4a", ofType: nil) {
            let url = URL(fileURLWithPath: path)
            audioItem = AudioItem(mode: .playback(fileUrl: url, startTime: nil))
        } else {
            audioItem = nil
        }

        audioItem?.statePublisher
            .sink { [unowned self] state in
                switch state {
                case .running:
                    self.setupTimer()
                case .paused, .stopped:
                    self.terminateTimer()
                }
            }
            .store(in: &cancellables)

        durationSubject
            .filter { $0 == .zero }
            .sink { [unowned self] _ in
                self.audioItem?.change(state: .stopped)
            }
            .store(in: &cancellables)
    }

    private func setupTimer() {

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .scan(durationSubject.value, { duration, _ in duration - 1 })
            .sink(receiveValue: { [weak self] v in self?.durationSubject.value = v })
    }

    private func terminateTimer() {
        timer?.cancel()
    }

    // MARK: PlayerViewModelDataProvidable

    override var style: PlayerViewControlsStyle {
        .playback
    }

    override var title: AnyPublisher<String, Never> {
        durationSubject
            .compactMap { DateComponentsFormatter.shortTimeString(timeIterval: $0) }
            .eraseToAnyPublisher()
    }
}
