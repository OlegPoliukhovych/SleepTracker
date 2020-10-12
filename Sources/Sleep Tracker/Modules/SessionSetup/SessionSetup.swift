//
//  SessionSetup.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 8/3/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

final class SessionSetup: ObservableObject {

    var relaxing: ValueSetting<TimeInterval>
    var noiseTracking: PlainSetting
    var alarm: ValueSetting<Date>

    @Published private(set) var isReadyToStart = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        relaxing = .init(
            kind: .relaxingSound,
            value: 300,
            options: stride(from: 300, to: 2000, by: 300).map{$0},
            viewInfo: (
                valueDescriptor: { "\(Int($0) / 60) min" },
                imageDescriptor: "timer"
            )
        )

        noiseTracking = .init(kind: .noiseRecording)

        alarm = .init(
            kind: .alarm,
            value: Calendar.current.nearestDate(matchingHour: 7, minute: 0),
            options: [],
            viewInfo: (
                valueDescriptor: { DateFormatter.shortTime(from: $0) },
                imageDescriptor: "alarm"
            )
        )

        Publishers
            .CombineLatest3(relaxing.$enabled, noiseTracking.$enabled, alarm.$enabled)
            .map { $0 || $1 || $2 }
            .eraseToAnyPublisher()
            .assign(to: \.isReadyToStart, on: self)
            .store(in: &cancellables)

        // Force disable alarm if local notifications are unauthorized

        Publishers.CombineLatest(alarm.$enabled.removeDuplicates(),
                                 UserNotificationCenter.shared.isUserNotificationsAuthorized)
            .dropFirst()
            .filter { $0.0 && !$0.1 }
            .setFailureType(to: Error.self)
            .flatMap { _ in UserNotificationCenter.shared.requestAuthorization()}
            .filter { !$0 }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(_):
                    // TODO: handle authorization error
                    break
                case .finished:
                    break
                }
            }, receiveValue: { _ in
                self.alarm.enabled = false
                // TODO: prompt user to enable notifications in settings
            })
            .store(in: &cancellables)
    }

    func prepareSession() -> SleepSession? {

        var steps = [SessionStep]()
        if relaxing.enabled {
            steps.append(RelaxingSoundStep(duration: relaxing.value))
        }
        if noiseTracking.enabled {
            steps.append(NoiseRecordingStep())
        }
        if alarm.enabled {
            steps.append(AlarmStep(date: Calendar.current.nearestDate(to: self.alarm.value, matching: [.hour, .minute])))
        }
        guard !steps.isEmpty,
            let session = try? SleepSession(steps: steps) else {
            return nil
        }
        return session
    }
}
