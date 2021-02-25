//
//  FileManagerStorageTests.swift
//  Sleep TrackerTests
//
//  Created by Oleg Poliukhovych on 2/21/21.
//  Copyright © 2021 Oleg Poliukhovych. All rights reserved.
//

import XCTest
@testable import Sleep_Tracker

class FileManagerStorageTests: XCTestCase {

    struct StorableMock: Storable, Equatable {
        let id: UUID
        var externalData: ExternalData { .none }

        init() {
            id = UUID()
        }
    }

    let mock: StorableMock = StorableMock()
    var fileManagerStorage: FileManagerStorage!

    override func setUp() {
        fileManagerStorage = FileManagerStorage(FileManager.default.temporaryDirectory)
    }

    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: mockUrl.path) {
            try FileManager.default.removeItem(at: mockUrl)
        }
    }

    func testRecordingsStorageURL() throws {
        let expectedUrl = FileManager.default.temporaryDirectory
            .appendingPathComponent("Recordings")
            .appendingPathComponent(mock.id.uuidString)
        let actualUrl = fileManagerStorage.recordingsStorageURL(for: mock.id)
        XCTAssertEqual(expectedUrl, actualUrl)
    }

    func testSaving() throws {
        fileManagerStorage.save(mock)

        guard let data = FileManager.default.contents(atPath: mockUrl.path) else {
            XCTFail("data not found at specified path")
            return
        }

        /// read data and compare it to original object
        let decoder = JSONDecoder()
        let value = try decoder.decode(StorableMock.self, from: data)

        XCTAssertEqual(mock, value)
    }

    func testDelete() {
        fileManagerStorage.save(mock)
        fileManagerStorage.delete(mock)

        let data = try? Data(contentsOf: mockUrl)
        XCTAssertNil(data)
    }

    func testRetrieving() {
        fileManagerStorage.save(mock)
        let results = fileManagerStorage.retrieve(StorableMock.self)
        XCTAssertTrue(results.contains(where: { $0.id == mock.id }))
    }

    var mockUrl: URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("AdditionalInfo")
            .appendingPathComponent(mock.id.uuidString)
    }
}
