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

final class AudioSession {

    enum Interruption {
        case began
        case ended(shouldResume: Bool)
    }

    var interruptionPublisher: AnyPublisher<Interruption, Never> {
        interruptionSubject.eraseToAnyPublisher()
    }

    private let interruptionSubject = PassthroughSubject<Interruption, Never>()

    private var cancellables = Set<AnyCancellable>()

    init?(audioItems: [AudioItem]) throws {
        let category: AVAudioSession.Category = audioItems.contains(where: { item in
            if case AudioItem.Mode.record(destination: _) = item.mode {
                return true
            }
            return false
        }) ? .playAndRecord : .playback

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(category)
            try session.setActive(true, options: [])
        } catch {
            throw error
        }

        if category == .playAndRecord, session.recordPermission == .undetermined {
            session.requestRecordPermission { _ in
                // TODO: handle recording permission request result
            }

        }
        subscribeToInterruptions()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    private func subscribeToInterruptions() {
        NotificationCenter.default
            .publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] notification in
                guard let userInfo = notification.userInfo,
                    let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                    let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                        return
                }

                switch type {
                case .began:
                    self?.interruptionSubject.send(.began)
                case .ended:
                    guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    self?.interruptionSubject.send(.ended(shouldResume: options.contains(.shouldResume)))
                default:
                    break
                }
        }
        .store(in: &cancellables)

    }
}
