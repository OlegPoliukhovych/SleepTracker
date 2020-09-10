//
//  AudioItem.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/4/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

struct AudioItem {

    enum Mode {
        case playback(fileUrl: URL, startTime: Date?)
        case record(destination: URL)
    }

    enum State {
        case running
        case paused
        case stopped
    }

    let mode: Mode

    var statePublisher: AnyPublisher<State, Never> {
        stateSubject
            .share()
            .eraseToAnyPublisher()
    }

    private let stateSubject = CurrentValueSubject<State, Never>(.running)

    func change(state: State) {
        stateSubject.send(state)
    }
}
