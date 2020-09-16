//
//  PlayerViewModel.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/16/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

protocol PlayerViewModelDataProvidable {
    var title: AnyPublisher<String, Never> { get }
    var isRunning: AnyPublisher<Bool, Never> { get }
    var toggleRunning: () -> Void { get }
    var skipItem: () -> Void { get }
}

final class PlayerViewModel: PlayerViewDisplayable {
    
    @Published var title: String = ""
    @Published var isRunning: Bool = false

    private let _toggleRunning: () -> Void
    private let _skipItem: () -> Void

    func toggleRunning() {
        _toggleRunning()
    }

    func skipItem() {
        _skipItem()
    }

    private var cancellables = Set<AnyCancellable>()

    init() {
        title = ""
        isRunning = false
        _toggleRunning = { }
        _skipItem = { }
    }

    convenience init(dataProvider: PlayerViewModelDataProvidable) {
        self.init(titlePublisher: dataProvider.title,
                  isRunningPublisher: dataProvider.isRunning,
                  toggleRunning: dataProvider.toggleRunning,
                  skipItem: dataProvider.skipItem)
    }

    init(
        titlePublisher: AnyPublisher<String, Never>,
        isRunningPublisher: AnyPublisher<Bool, Never>,
        toggleRunning: @escaping () -> Void,
        skipItem: @escaping () -> Void
    ) {
        _toggleRunning = toggleRunning
        _skipItem = skipItem

        titlePublisher
            .sink(receiveValue: { [unowned self] in self.title = $0 })
            .store(in: &cancellables)

        isRunningPublisher
            .sink(receiveValue: { [unowned self] in self.isRunning = $0 })
            .store(in: &cancellables)
    }
}
