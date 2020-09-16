//
//  SessionStep.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/15/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

protocol SessionStep: PlayerViewModelDataProvidable {
    var audioItem: AudioItem? { get }
    var skip: AnyPublisher<Void, Never> { get }
    func skipStep()
}

extension PlayerViewModelDataProvidable where Self: SessionStep {

    var toggleRunning: () -> Void {
        audioItem?.togglePlayback ?? { }
    }

    var skipItem: () -> Void {
        skipStep
    }

    var isRunning: AnyPublisher<Bool, Never> {
        audioItem?.statePublisher
            .map { $0 == .running }
            .eraseToAnyPublisher() ?? Just(false).eraseToAnyPublisher()
    }

}
