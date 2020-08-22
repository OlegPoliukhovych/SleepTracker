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

    var session: SessionSetup!

    override func setUpWithError() throws {
        try super.setUpWithError()
        session = SessionSetup()
    }

    override func tearDownWithError() throws {
        session = nil
        try super.tearDownWithError()
    }

    func testSessionIsReadyToStartIsFalseByDefault() throws {
        XCTAssertEqual(session.isReadyToStart, false, "new session should be disabled to start by default")
    }

    func testSessionIsReadyToStartIfOnlyRelaxingEnabled() throws {
        session.relaxing.enabled = true
        XCTAssertEqual(session.isReadyToStart, true, "session should be able to start if at least relaxong sound is enabled")
    }

    func testSessionIsReadyToStartIfOnlyNoiseRecordingEnabled() throws {
        session.noiseTracking.enabled = true
        XCTAssertEqual(session.isReadyToStart, true, "session should be able to start if at least noise recording is enabled")
    }

    func testSessionIsReadyToStartIfOnlyAlarmEnabled() throws {
        session.alarm.enabled = true
        XCTAssertEqual(session.isReadyToStart, true, "session should be able to start if at least alarm is enabled")
    }

    func testRelaxingSettingValueSelection() throws {
        session.relaxing.selectValue(at: 1)
        XCTAssertEqual(session.relaxing.value, 600, "selected value is not related to provided values sequence")
    }

    func testRelaxingSettingValueSelectioOutOfBounds() throws {
        let currentValue = session.relaxing.value
        session.relaxing.selectValue(at: 10)
        XCTAssertEqual(session.relaxing.value, currentValue, "selected value is not related to provided values sequence")
    }

    func testRelaxingSoundValueTexts() throws {
        let texts = session.relaxing.options?.map { "\(Int($0)/60)\nmin"}
        let values = session.relaxing.values
        XCTAssertEqual(texts, values, "texts doesnt match")
    }

    func testRelaxingSoundValueText() throws {
        XCTAssertEqual(session.relaxing.valueDescription, "5 min", "relaxing sound value description incorrect")
    }

    func testAlarmValueDescription() throws {
        XCTAssertEqual(session.alarm.valueDescription, "7:00 AM", "relaxing sound value description incorrect")
    }

    func testSessionIsReadyToStartIfAllOptionsAreEnabled() throws {
        session.relaxing.enabled = true
        session.noiseTracking.enabled = true
        session.alarm.enabled = true
        XCTAssertEqual(session.isReadyToStart, true, "session should be able to start if all options are enabled")
    }
}
