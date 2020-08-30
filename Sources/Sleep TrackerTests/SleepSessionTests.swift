//
//  SleepSessionTests.swift
//  Sleep TrackerTests
//
//  Created by Oleg Poliukhovych on 8/26/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import XCTest
@testable import Sleep_Tracker

final class SleepSessionTests: XCTestCase {

    var session: SleepSession!

    var steps: [SessionStep] {
        [SessionStepModel(kind: .relaxingSound),
         SessionStepModel(kind: .noiseRecording),
         SessionStepModel(kind: .alarm)]
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        session = try! SleepSession(steps: steps)
    }

    override func tearDownWithError() throws {
        session = nil
        try super.tearDownWithError()
    }

    func testInitialStepIsEqualToFirstElementInProvidedSteps() throws {
        let firstStep = steps.first!
        let sessionFirstStep = session.currentStep
        XCTAssertEqual(firstStep.kind, sessionFirstStep.kind, "Current step is not equal to provided one in steps array")
    }

    func testCurrentStepChange() throws {
        let currentStep = session.currentStep
        currentStep.skipStep()
        let newStep = session.currentStep
        XCTAssertNotEqual(currentStep.kind, newStep.kind, "Steps should be different")
    }

    func testSessionExitWhenStepsReachedOut() throws {
        session.currentStep.skipStep() // Relaxing Sound to noiseRecording
        session.currentStep.skipStep() // Noise Recording to Alarm
        session.currentStep.skipStep() // Alarm not changed because it is last step so session should be terrminated
        XCTAssert(!session.isRunning, "Session should be ended when alarm step calls 'next'")
    }

}
