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
    var audioItem: AudioItem? { get }
    var skip: AnyPublisher<Void, Never> { get }
    func skipStep()
}

final class SleepSession: ObservableObject {

    private let audioProvider: AudioProvider
    @Published private(set) var currentStep: SessionStep
    @Published private(set) var isRunning: Bool = true

    private var iterator: IndexingIterator<[SessionStep]>
    private var cancellables = Set<AnyCancellable>()

    init?(steps: [SessionStep]) throws {

        iterator = steps.makeIterator()

        guard let first = iterator.next() else {
            return nil
        }

        audioProvider = AudioProvider(audioItems: steps.compactMap { $0.audioItem })

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

        $currentStep
            .compactMap { $0.audioItem }
            .sink { [unowned self] audioItem in
                self.audioProvider.setAccent(audioItem: audioItem)
            }
            .store(in: &cancellables)
    }

}

struct SessionStepModel: SessionStep {
    var audioItem: AudioItem?

    let kind: Kind
    var skip: AnyPublisher<Void, Never> {
        skipSubject
            .first()
            .eraseToAnyPublisher()
    }

    private let skipSubject = PassthroughSubject<Void, Never>()

    init(kind: Kind) {
        self.kind = kind
        audioItem = nil
    }

    func skipStep() {
        skipSubject.send()
    }
}
