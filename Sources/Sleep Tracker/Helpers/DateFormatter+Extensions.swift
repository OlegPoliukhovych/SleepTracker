//
//  DateFormatter+Extensions.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 10/9/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation

extension DateFormatter {

    static private var shortTimeStyleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()


    static func shortTime(from date: Date) -> String {
        shortTimeStyleFormatter.string(from: date)
    }
}
