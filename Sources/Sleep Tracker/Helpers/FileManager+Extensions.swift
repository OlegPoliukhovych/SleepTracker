//
//  FileManager+Extensions.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/17/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation

extension FileManager {

    var recordingsFolderUrl: URL {

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderPath = documentsDirectory.appendingPathComponent("Recordings")
        if !FileManager.default.fileExists(atPath: folderPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: folderPath,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        return folderPath
    }
}
