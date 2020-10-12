//
//  SessionSetting.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 10/8/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

/// Desribes possible setting kinds that can be used for identification, pattern matching, etc
enum SettingKind: String, CustomStringConvertible {
    case relaxingSound = "Relaxing sound"
    case noiseRecording = "Noise recording"
    case alarm = "Alarm"

    var description: String {
        rawValue
    }
}

/// Base setting requirements protocol
protocol Settingable {
    var kind: SettingKind { get }
    var enabled: Bool { get set }
}

/// Extended setting requirements protocol for entity that contains concrete value representing setting and options as well
protocol ValueSettingable: Settingable {
    associatedtype T
    var value: T { get }
    var options: [T] { get }
}

/// Entity representing simplest setting that provides only option to enable or disable it
class PlainSetting: Settingable {
    private(set) var kind: SettingKind
    @Published var enabled: Bool

    init(
        kind: SettingKind,
        enabled: Bool = false
    ) {
        self.kind = kind
        self.enabled = enabled
    }
}

extension PlainSetting: SettingDisplayable {
    var title: String { kind.description }
}

/// Helper structure as store for modifiers used to prepare  UI related info
typealias ViewInfo<T> = (
    valueDescriptor: (T) -> String,
    imageDescriptor: String
)

/// Entity representing setting that can have some specific value and options to choose from
final class ValueSetting<T>: PlainSetting, ValueSettingable {

    var value: T {
        willSet {
            objectWillChange.send()
        }
    }
    private(set) var options: [T]

    let viewInfo: ViewInfo<T>

    init(
        kind: SettingKind,
        enabled: Bool = false,
        value: T,
        options: [T],
        viewInfo: ViewInfo<T>
    ) {
        self.value = value
        self.options = options
        self.viewInfo = viewInfo
        super.init(kind: kind, enabled: enabled)
    }

}

extension ValueSetting: SettingOptionable {
    var imageName: String? { viewInfo.imageDescriptor }
    var valueDescription: String { viewInfo.valueDescriptor(value) }
}

extension ValueSetting: OptionSelectable {

    var values: [String] { options.map{ self.viewInfo.valueDescriptor($0) } }

    func selectValue(at index: Int) {
        guard options.count > index else { return }
        value = options[index]
    }
}
