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

    @Published private(set) var isRunning: Bool = true
    @Published private(set) var timeLeft: String = ""
    private(set) var audioItem: AudioItem?

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

        if let path = Bundle.main.path(forResource: "nature.m4a", ofType: nil) {
            let url = URL(fileURLWithPath: path)
            audioItem = AudioItem(mode: .playback(fileUrl: url, startTime: nil))
        } else {
            audioItem = nil
        }

        audioItem?.statePublisher
            .sink { [unowned self] state in
                switch state {
                case .running:
                    self.setupTimer()
                    self.isRunning = true
                case .paused, .stopped:
                    self.terminateTimer()
                    self.isRunning = false
                }
            }
            .store(in: &cancellables)

        durationSubject
            .compactMap { [unowned self] in self.formatter.string(from: $0) }
            .sink(receiveValue: { [unowned self] s in self.timeLeft = s })
            .store(in: &cancellables)

        durationSubject
            .filter { $0 == .zero }
            .sink { [unowned self] _ in
                self.isRunning = false
                self.skipStep()
            }
            .store(in: &cancellables)

        skipSubject
            .sink { [unowned self] _ in
                self.audioItem?.change(state: .stopped)
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

    func toggleRunning() {
        audioItem?.change(state: isRunning ? .paused : .running)
    }

    func skipStep() {
         skipSubject.send()
    }
}
