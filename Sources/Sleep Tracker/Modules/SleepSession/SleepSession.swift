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
    @Published private(set) var currentStepViewModel: PlayerViewModel!
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isAlarmFired: Bool = false
    private var recordingsInfo: SessionRecordingsInfo
    private let storageProvider: StorageProvider
    private var cancellables = Set<AnyCancellable>()

    init?(stepsInfo: [SettingInfo], storageProvider: StorageProvider = FileManagerStorage()) throws {

        let sessionInfo = SessionRecordingsInfo(storagePathProvider: storageProvider.recordingsStorageURL(for:))
        let steps = stepsInfo.map { element -> SessionStep in
            switch element {
            case .relaxing(let timeInterval):
                return RelaxingSoundStep(duration: timeInterval)
            case .recording(timeout: let timeout):
                return NoiseRecordingStep(recordingUrl: sessionInfo.recordingsPath,
                                          timeout: timeout)
            case .alarm(let date):
                return AlarmStep(date: date)
            }
        }

        self.storageProvider = storageProvider
        audioProvider = try? AudioProvider(audioItems: steps.compactMap { $0.audioItem })
        self.recordingsInfo = sessionInfo
        setup(steps: steps)
    }

    private func setup(steps: [SessionStep]) {

        var connectableStepsPublisher: Cancellable?

        let stepsPublisher = Publishers.StepsPublisher(steps: steps)
            .handleEvents(receiveCompletion: { [unowned self] _ in self.isRunning = false })
            .share()
            .makeConnectable()

        let isRunningPublisher = $isRunning.dropFirst()

        // connect stepsPublisher on session appearance
        isRunningPublisher
            .filter { $0 == true }
            .first()
            .sink { _ in connectableStepsPublisher = stepsPublisher.connect() }
            .store(in: &cancellables)

        // cancel subscription to stepsPublisher
        isRunningPublisher
            .filter { $0 == false }
            .sink { _ in connectableStepsPublisher?.cancel() }
            .store(in: &cancellables)

        // create viewmodel for player view from current step
        stepsPublisher
            .map { PlayerViewModel(dataProvider: $0) }
            .sink { [unowned self] in self.currentStepViewModel = $0 }
            .store(in: &cancellables)

        // attach audio item of current step to audio provider
        stepsPublisher
            .compactMap { $0.audioItem }
            .sink { [unowned self] in self.audioProvider?.setAccent(audioItem: $0)}
            .store(in: &cancellables)

        // get start date when recording starts
        steps
            .first(as: NoiseRecordingStep.self)?
            .onStart
            .sink { [unowned self] in self.recordingsInfo.set(start: $0) }
            .store(in: &cancellables)

        // set finish date when recording step finishes
        // TODO: combine with `applicationWillTerminate(_:)` notification so finish date will be set either on step finish or app termination
        steps
            .first(as: NoiseRecordingStep.self)?
            .skip
            .map { _ in Date() }
            .sink { [unowned self] in
                self.recordingsInfo.set(finish: $0)
                self.storageProvider.save(self.recordingsInfo)
            }
            .store(in: &cancellables)

        // Mark that alarm is fired so view can draw the alarm view
        guard let alarmStep = steps.first(as: AlarmStep.self) else {
            return
        }

        alarmStep
            .onAlarm
            .sink { [unowned self] _ in self.isAlarmFired = true }
            .store(in: &cancellables)

        // drop steps on alarm and make alarm step as "current"
        Publishers.CombineLatest($isAlarmFired, stepsPublisher)
            .filter { $0.0 == true && !($0.1 is AlarmStep) }
            .compactMap { $0.1 }
            .receive(on: DispatchQueue.main)
            .sink { $0.skipStep() }
            .store(in: &cancellables)

        UserNotificationCenter.shared.setAlarmNotification(date: alarmStep.fireDate)

        $isRunning
            .dropFirst()
            .filter { !$0 }
            .sink { _ in UserNotificationCenter.shared.cancelAlarmNotification() }
            .store(in: &cancellables)
    }

    func start() {
        isRunning = true
    }

    func cancel() {
        storageProvider.delete(recordingsInfo)
        isRunning = false
    }
}

// Not necessary, just to encapsulate steps iteration in one place
// Also I believe it can be done much better

private extension Publishers {

    struct StepsPublisher: Publisher {

        typealias Output = SessionStep
        typealias Failure = Never

        private let elements: [SessionStep]

        init(steps: [SessionStep]) {
            elements = steps
        }

        func receive<S>(subscriber: S) where
            S : Subscriber,
            Self.Failure == S.Failure,
            Self.Output == S.Input
        {
            let subscription = StepsSubscription(subscriber, elements: elements)
            subscriber.receive(subscription: subscription)
        }
    }

    private final class StepsSubscription<S: Subscriber>: Subscription where
        S.Input == SessionStep,
        S.Failure == Never {

        private var subscriber: S?
        private let elements: [S.Input]

        init(_ subscriber: S, elements: [S.Input]) {
            self.subscriber = subscriber
            self.elements = elements

            var iterator = elements.makeIterator()

            elements
                .publisher
                .flatMap { $0.skip }
                .map { iterator.next() }
                .prepend(iterator.next())
                .compactMap { element in
                    guard let e = element else {
                        subscriber.receive(completion: .finished)
                        return nil
                    }
                    return e
                }
                .receive(subscriber: subscriber)
        }

        func request(_ demand: Subscribers.Demand) { }

        func cancel() {
            subscriber = nil
        }
    }
}

