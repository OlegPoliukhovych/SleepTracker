//
//  UserNotificationCenterDelegate.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/25/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import UIKit
import Combine

final class UserNotificationCenterDelegate {

    // MARK: Public API
    static var shared = UserNotificationCenterDelegate()
    var notificationReceived: AnyPublisher<UNNotification, Never> {
        notificationReceivedSubject
            .share()
            .eraseToAnyPublisher()
    }

    // MARK: Private API

    private let delegate: NotificationCenterDelegate
    private let notificationReceivedSubject = PassthroughSubject<UNNotification, Never>()

    private init() {
        delegate = NotificationCenterDelegate(onRecieve: notificationReceivedSubject)
        UNUserNotificationCenter.current().delegate = delegate
    }

    private final class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {

        private let _onReceive: PassthroughSubject<UNNotification, Never>

        init(onRecieve: PassthroughSubject<UNNotification, Never>) {
            _onReceive = onRecieve
        }

        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void) {
            _onReceive.send(notification)
            completionHandler(UNNotificationPresentationOptions.init(rawValue: 0))
        }

        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
            _onReceive.send(response.notification)
            completionHandler()
        }
    }
}
