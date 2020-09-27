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

    private var iterator: IndexingIterator<[SessionStep]>
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
            .compactMap { $0.audioItem }
            .sink { [unowned self] audioItem in
                self.audioProvider?.setAccent(audioItem: audioItem)
                audioItem.change(state: .running)
            }
            .store(in: &cancellables)

        $currentStep
            .sink { [unowned self] in self.currentStepViewModel = .init(dataProvider: $0) }
            .store(in: &cancellables)

        UserNotificationCenterDelegate.shared.notificationReceived
            .sink { notification in
                // TODO: Provide alarm fired interface
            }
            .store(in: &cancellables)
    }

}
