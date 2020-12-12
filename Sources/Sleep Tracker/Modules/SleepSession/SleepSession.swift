//
//  SleepSession.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 8/24/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

final class SleepSession: ObservableObject {

    private let audioProvider: AudioProvider?
    @Published private var currentStep: SessionStep
    @Published private(set) var currentStepViewModel: PlayerViewModel!
    @Published private(set) var isRunning: Bool = true
    @Published private(set) var isAlarmFired: Bool = false

    private var iterator: IndexingIterator<[SessionStep]>
    private var timer: Cancellable?
    private var cancellables = Set<AnyCancellable>()

    init?(steps: [SessionStep]) throws {

        iterator = steps.makeIterator()

        guard let first = iterator.next() else {
            return nil
        }

        audioProvider = try? AudioProvider(audioItems: steps.compactMap { $0.audioItem })

        currentStep = first

        steps
            .publisher
            .flatMap { $0.skip }
            .sink { [weak self] in
                guard let next = self?.iterator.next() else {
                    self?.isRunning = false
                    return
                }
                self?.currentStep = next
            }
            .store(in: &cancellables)

        $currentStep
            .sink { [unowned self] in self.currentStepViewModel = .init(dataProvider: $0) }
            .store(in: &cancellables)

        // Using timer to mark if alarm fired because local notification can be skipped in background
        if let alarmStep = steps.first(where: { $0 is AlarmStep }),
           let audioItem = alarmStep.audioItem,
           case let AudioItem.Mode.playback(_, date) = audioItem.mode,
           let alarmDate = date {

            timer = Timer.TimerPublisher(interval: alarmDate.timeIntervalSinceNow, runLoop: .current, mode: .default)
                .autoconnect()
                .sink { [weak self] _ in
                    steps.dropLast().forEach({ $0.skipStep() })
                    self?.isAlarmFired = true
                }
        }
    }

    func start() {
        $currentStep
            .compactMap { $0.audioItem }
            .sink { [unowned self] audioItem in
                self.audioProvider?.setAccent(audioItem: audioItem)
            }
            .store(in: &cancellables)
    }

    deinit {
        timer?.cancel()
    }

}
