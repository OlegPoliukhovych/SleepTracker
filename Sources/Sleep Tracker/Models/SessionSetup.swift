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

    var relaxing: Setting<TimeInterval>
    var noiseTracking: Setting<Void>
    var alarm: Setting<Date>

    @Published private(set) var isReadyToStart = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        relaxing = .init(kind: .relaxingSound, value: 300, values: [300, 600, 900, 1200, 1500])
        let defaultAlarmTimeDate = Calendar.current.date(from: DateComponents(hour: 7, minute: 0))!
        alarm = .init(kind: .alarm, value: defaultAlarmTimeDate, values: nil)
        noiseTracking = .init(kind: .noiseRecording, value: (), values: nil)

        Publishers
            .CombineLatest3(relaxing.$enabled, noiseTracking.$enabled, alarm.$enabled)
            .map { $0 || $1 || $2 }
            .eraseToAnyPublisher()
            .assign(to: \.isReadyToStart, on: self)
            .store(in: &cancellables)
    }
}

enum Kind: String, CustomStringConvertible {
    case relaxingSound = "Relaxing sound"
    case noiseRecording = "Noise recording"
    case alarm = "Alarm"

    var description: String {
        rawValue
    }
}

class Setting<T>: Identifiable {
    @Published var value: T
    var options: [T]?
    let kind: Kind
    @Published var enabled: Bool

    init(
        kind: Kind,
        enabled: Bool = false,
        value: T,
        values: [T]?
    ) {
        self.kind = kind
        self.enabled = enabled
        self.value = value
        self.options = values
    }

}

extension Setting: SettingDisplayable {
    var title: String {
        return kind.description
    }
}

extension Setting: SettingOptionable {

    var imageName: String? {
        switch kind {
        case .relaxingSound:
            return "timer"
        case .alarm:
            return "alarm"
        case .noiseRecording:
            return nil
        }
    }

    var valueDescription: String {
        switch (kind, value) {
        case (.relaxingSound, let v as TimeInterval):
            return "\(Int(v) / 60) min"
        case (.alarm, let v as Date):
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter.string(from: v)
        default:
            return ""
        }
    }
}

extension Setting: OptionSelectable {

    var values: [String] {
        switch (kind, value) {
        case (.relaxingSound, _):
            guard let options = options as? [TimeInterval] else { return [] }
            return options.map { "\(Int($0) / 60)\nmin"}
        default:
            return []
        }
    }

    func selectValue(at index: Int) {
        guard let options = options,
            options.count > index else {
                return
        }
        value = options[index]
    }
}
