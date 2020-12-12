//
//  SessionSetupTests.swift
//  Sleep TrackerTests
//
//  Created by Oleg Poliukhovych on 8/21/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import XCTest
@testable import Sleep_Tracker

final class SessionSetupTests: XCTestCase {

    let session = SessionSetup()

    func testSessionIsReadyToStartIsFalseByDefault() {
        XCTAssertEqual(session.isReadyToStart, false, "new session should be disabled to start by default")
    }

    func testSessionIsReadyToStartIfOnlyRelaxingEnabled() {
        session.relaxing.enabled = true
        XCTAssertEqual(session.isReadyToStart, true, "session should be able to start if at least relaxong sound is enabled")
    }

    func testSessionIsReadyToStartIfOnlyNoiseRecordingEnabled() {
        session.noiseTracking.enabled = true
        XCTAssertEqual(session.isReadyToStart, true, "session should be able to start if at least noise recording is enabled")
    }

    func testSessionIsReadyToStartIfOnlyAlarmEnabled() {
        session.alarm.enabled = true
        XCTAssertEqual(session.isReadyToStart, true, "session should be able to start if at least alarm is enabled")
    }

    func testRelaxingSettingValueSelection() {
        session.relaxing.selectValue(at: 1)
        XCTAssertEqual(session.relaxing.value, 600, "selected value is not related to provided values sequence")
    }

    func testRelaxingSettingValueSelectioOutOfBounds() {
        let currentValue = session.relaxing.value
        session.relaxing.selectValue(at: 10)
        XCTAssertEqual(session.relaxing.value, currentValue, "selected value is not related to provided values sequence")
    }

    func testRelaxingSoundValueTexts() {
        let texts = session.relaxing.options.map { "\(Int($0)/60) min"}
        let values = session.relaxing.values
        XCTAssertEqual(texts, values, "texts doesn't match")
    }

    func testRelaxingSoundValueText() {
        XCTAssertEqual(session.relaxing.valueDescription, "5 min", "relaxing sound value description incorrect")
    }

    func testAlarmValueDescription() {
        XCTAssertEqual(session.alarm.valueDescription, "7:00 AM", "relaxing sound value description incorrect")
    }

    func testSessionIsReadyToStartIfAllOptionsAreEnabled() {
        session.relaxing.enabled = true
        session.noiseTracking.enabled = true
        session.alarm.enabled = true
        XCTAssertEqual(session.isReadyToStart, true, "session should be able to start if all options are enabled")
    }

    func testSessionCreation() {
        session.relaxing.enabled = true
        session.noiseTracking.enabled = true
        session.alarm.enabled = true
        let sleepSession = session.prepareSession()
        XCTAssertNotNil(sleepSession, "Sleep session should be created if options are set to 'enabled'")
    }
}
