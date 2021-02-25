//
//  FileManagerStorage.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 2/21/21.
//  Copyright © 2021 Oleg Poliukhovych. All rights reserved.
//

import Foundation

struct FileManagerStorage: StorageProvider {

    private let fileManager = FileManager.default
    private let rootDirectory: URL

    /// optionally provide root folder url, implemented for possibility to unit test with temp directory
    init(_ rootDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]) {
        self.rootDirectory = rootDirectory
    }

    private init() {
        rootDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func recordingsStorageURL(for sessionId: UUID) -> URL {
        sessionFolderPath(sessionId: sessionId)
    }

    func save<S: Storable>(_ v: S) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(v) else { return }
        let path = additionalInfoFolderUrl.appendingPathComponent(v.id.uuidString)
        try? data.write(to: path)
    }

    func delete<S: Storable>(_ v: S) {
        let url = additionalInfoFolderUrl.appendingPathComponent(v.id.uuidString)
        guard fileManager.fileExists(atPath: url.path),
              let _ = try? fileManager.removeItem(at: url) else {
            return
        }
        if case let .files(destination: url, shouldDeleteWithObject: shouldDelete) = v.externalData, shouldDelete {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    func retrieve<S: Storable>(_ v: S.Type) -> [S] {
        let url = additionalInfoFolderUrl
        guard let fileNames = try? fileManager.contentsOfDirectory(atPath: url.path) else {
            return []
        }
        let decoder = JSONDecoder()
        let files = try? fileNames
            .map { path -> S in
                let data = try Data(contentsOf: url.appendingPathComponent(path))
                return try decoder.decode(S.self, from: data)
            }
            .compactMap { $0 }
        return files ?? []
    }

}

private extension FileManagerStorage {

    var recordingsFolderUrl: URL {
        folderUrl(named: "Recordings")
    }

    var additionalInfoFolderUrl: URL {
        folderUrl(named: "AdditionalInfo")
    }

    func sessionFolderPath(sessionId: UUID) -> URL {
        let url = recordingsFolderUrl.appendingPathComponent(sessionId.uuidString)
        let path = url.pathComponents.suffix(2).joined(separator: "/")
        return folderUrl(named: path)
    }

    private func folderUrl(named: String) -> URL {

        let folderPath = rootDirectory.appendingPathComponent(named)

        if !fileManager.fileExists(atPath: folderPath.path) {
            do {
                try createDirectory(at: folderPath)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        return folderPath
    }

    private func createDirectory(at path: URL) throws {
        do {
            try fileManager.createDirectory(at: path,
                                            withIntermediateDirectories: false,
                                            attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
}
