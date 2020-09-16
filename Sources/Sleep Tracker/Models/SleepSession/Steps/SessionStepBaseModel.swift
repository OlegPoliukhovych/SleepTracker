//
//  SessionStepBaseModel.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/15/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

class SessionStepBaseModel: SessionStep {
    
    // MARK: SessionStep
    var audioItem: AudioItem?

    var skip: AnyPublisher<Void, Never> {
        skipSubject
            .first()
            .eraseToAnyPublisher()
    }

    func skipStep() {
        skipSubject.send()
    }

    // MARK: Helpers
    lazy private var skipSubject: PassthroughSubject<Void, Never> = {
        let subject = PassthroughSubject<Void, Never>()
            subject.sink { [unowned self] _ in
                self.audioItem?.change(state: .stopped)
            }
            .store(in: &cancellables)

        return subject
    }()

    var cancellables = Set<AnyCancellable>()

    // MARK: PlayerViewModelDataProvidable
    
    var title: AnyPublisher<String, Never> {
        Empty().eraseToAnyPublisher()
    }
}
