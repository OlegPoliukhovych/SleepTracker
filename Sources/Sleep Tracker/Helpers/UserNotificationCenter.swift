//
//  UserNotificationCenter.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/25/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import UIKit
import Combine

final class UserNotificationCenter: NotificationCenterProvider {

    static let shared = UserNotificationCenter()

    private let alarmIdentifier = "com.sleep-tracker.alarm"
    
    var isUserNotificationsAuthorized: AnyPublisher<Bool, Never> {
        isUserNotificationsAuthorizedSubject
            .dropFirst()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private let isUserNotificationsAuthorizedSubject = PassthroughSubject<Bool, Never>()

    private init() {
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .subscribe(Subscribers.Sink(receiveCompletion: { _ in },
                                        receiveValue: { _ in self.checkAuthorizationStatus() }))
        checkAuthorizationStatus()
    }

    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status = settings.authorizationStatus
            self.isUserNotificationsAuthorizedSubject.send(status == .authorized || status == .provisional)
        }
    }
    
    func requestAuthorization() -> AnyPublisher<Bool, Error> {
        Future { promise in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
                if let err = error {
                    promise(.failure(err))
                    return
                }
                self.isUserNotificationsAuthorizedSubject.send(granted)
                promise(.success(granted))
            }
        }
        .eraseToAnyPublisher()
    }

    func setAlarmNotification(date: Date) {

        let content = UNMutableNotificationContent()
        content.title = "Wake up"

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: self.alarmIdentifier,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
