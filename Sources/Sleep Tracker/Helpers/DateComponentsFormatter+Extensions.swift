//
//  DateComponentsFormatter+Extensions.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/14/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation

extension DateComponentsFormatter {

    static func shortTimeString(timeIterval: TimeInterval) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeIterval)
    }
}
