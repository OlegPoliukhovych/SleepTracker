//
//  NotificationCenterProvider.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/25/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import Combine

protocol NotificationCenterProvider {

    /// Checks if notifications authorized
    var isUserNotificationsAuthorized: AnyPublisher<Bool, Never> { get }

    /// Request authorization for enabling notifications
    func requestAuthorization() -> AnyPublisher<Bool, Error>

    /// Sets alarm local notification
    func setAlarmNotification(date: Date)

    func cancelAlarmNotification()
    
}
