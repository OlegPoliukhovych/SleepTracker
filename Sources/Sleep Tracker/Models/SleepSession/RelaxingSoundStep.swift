//
//  RelaxingSoundStep.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 8/30/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

final class RelaxingSoundStep: SessionStep, PlayerViewDisplayable {

    let kind: Kind
    var skip: AnyPublisher<Void, Never> {
        skipSubject
            .first()
            .eraseToAnyPublisher()
    }

    private let skipSubject = PassthroughSubject<Void, Never>()

    @Published var isRunning: Bool = true
    @Published private(set) var timeLeft: String = ""

    private var timer: Cancellable?
    private var durationSubject: CurrentValueSubject<TimeInterval, Never>

    private var cancellables = Set<AnyCancellable>()

    lazy private var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    init(kind: Kind, duration: TimeInterval) {
        self.kind = kind
        durationSubject = .init(duration)
        
        durationSubject
            .compactMap { [weak self] in self?.formatter.string(from: $0) }
            .sink(receiveValue: { [weak self] s in self?.timeLeft = s })
            .store(in: &cancellables)

        durationSubject
            .filter { $0 == .zero }
            .sink { [unowned self] _ in
                self.isRunning = false
                self.skipStep()
            }
            .store(in: &cancellables)

        $isRunning
            .sink { [unowned self] isRunning in
                isRunning ? self.setupTimer() : self.terminateTimer()
            }
            .store(in: &cancellables)
    }

    private func setupTimer() {

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .scan(durationSubject.value, { duration, _ in duration - 1 })
            .sink(receiveValue: { [weak self] v in self?.durationSubject.value = v })
    }

    private func terminateTimer() {
        timer?.cancel()
    }

    func skipStep() {
         skipSubject.send()
    }
}
