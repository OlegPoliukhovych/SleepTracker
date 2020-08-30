//
//  SleepSession.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 8/24/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

protocol SessionStep {
    var kind: Kind { get }
    var skip: AnyPublisher<Void, Never> { get }
    func skipStep()
}

final class SleepSession: ObservableObject {

    @Published private(set) var currentStep: SessionStep
    @Published private(set) var isRunning: Bool = true

    private var iterator: IndexingIterator<[SessionStep]>
    private var cancellables = Set<AnyCancellable>()

    init?(steps: [SessionStep]) throws {

        iterator = steps.makeIterator()

        guard let first = iterator.next() else {
            return nil
        }
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
    }

}

struct SessionStepModel: SessionStep {
    let kind: Kind
    var skip: AnyPublisher<Void, Never> {
        skipSubject
            .first()
            .eraseToAnyPublisher()
    }

    private let skipSubject = PassthroughSubject<Void, Never>()

    init(kind: Kind) {
        self.kind = kind
    }

    func skipStep() {
        skipSubject.send()
    }
}
