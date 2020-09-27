//
//  AlarmStep.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/16/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

final class AlarmStep: SessionStepBaseModel {

    init(date: Date) {
        super.init()

        if let path = Bundle.main.path(forResource: "alarm.m4a", ofType: nil) {
            let url = URL(fileURLWithPath: path)
            self.audioItem = AudioItem(mode: .playback(fileUrl: url, startTime: date))
        } else {
            self.audioItem = nil
        }
    }
}
