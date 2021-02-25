//
//  SessionRecordingsInfo.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 2/14/21.
//  Copyright © 2021 Oleg Poliukhovych. All rights reserved.
//

import Foundation

struct SessionRecordingsInfo: Storable {
    let id: UUID
    private(set) var start: Date!
    private(set) var finish: Date!
    let recordingsPath: URL

    init(storagePathProvider: (UUID) -> URL) {
        id = UUID()
        recordingsPath = storagePathProvider(id)
    }

    mutating func set(start date: Date) {
        start = date
    }

    mutating func set(finish date: Date) {
        finish = date
    }

    var externalData: ExternalData {
        .files(destination: recordingsPath, shouldDeleteWithObject: true)
    }
}
