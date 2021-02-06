//
//  AudioSession.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 8/30/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import UIKit
import AVFoundation
import Combine

extension AVAudioSession {

    enum Interruption {
        case began
        case ended(shouldResume: Bool)
    }

    func setup(audioItems: [AudioItem]) throws {
        do {
            try setCategory(.playAndRecord, options: .defaultToSpeaker)
            try setActive(true)
        } catch {
            throw error
        }

        if audioItems.contains(where: {
            if case .record = $0.mode {
                return true
            }
            return false
        }), recordPermission == .undetermined {
            requestRecordPermission { _ in
                // TODO: handle recording permission request result
            }
        }

        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    var interruptionPublisher: AnyPublisher<Interruption, Never> {
        NotificationCenter.default
            .publisher(for: AVAudioSession.interruptionNotification)
            .compactMap({ notification -> AVAudioSession.Interruption? in
                guard let userInfo = notification.userInfo,
                    let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                    let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                        return nil
                }

                switch type {
                case .began:
                    return .began
                case .ended:
                    guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return nil }
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    return .ended(shouldResume: options.contains(.shouldResume))
                @unknown default:
                    return nil
                }
            })
            .eraseToAnyPublisher()
    }
}
