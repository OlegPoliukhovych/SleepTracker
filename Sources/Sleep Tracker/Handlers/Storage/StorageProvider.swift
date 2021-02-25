//
//  StorageProvider.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 2/12/21.
//  Copyright © 2021 Oleg Poliukhovych. All rights reserved.
//

import Foundation

enum ExternalData {
    case none
    case files(destination: URL, shouldDeleteWithObject: Bool)
}

protocol Storable: Codable {
    var id: UUID { get }
    var externalData: ExternalData { get }
}

protocol StorageProvider {
    func recordingsStorageURL(for sessionId: UUID) -> URL
    func save<S: Storable>(_ v: S)
    func delete<S: Storable>(_ v: S)
    func retrieve<S: Storable>(_ v: S.Type) -> [S]
}
