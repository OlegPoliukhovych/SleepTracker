//
//  Calendar+Extensions.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/24/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation

extension Calendar {

    func nearestDate(
        after date: Date = Date(),
        matchingHour hour: Int,
        minute: Int
    ) -> Date {

        if let nextDate = Calendar.current.nextDate(after: date,
                                                    matching: DateComponents(hour: hour, minute: minute),
                                                    matchingPolicy: .nextTime) {
            return nextDate
        }
        return date
    }

    func nearestDate(
        to date: Date,
        matching components: Set<Component>
    ) -> Date {

        let components = Calendar.current.dateComponents(components, from: date)

        guard let hour = components.hour,
              let minute = components.minute
        else {
            return date
        }
        return nearestDate(matchingHour: hour, minute: minute)
    }

}
