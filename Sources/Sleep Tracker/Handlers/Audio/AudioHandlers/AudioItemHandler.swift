//
//  AudioItemHandler.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/10/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation

protocol AudioItemHandler {
    func prepare()
    func run()
    func pause()
    func finish()
}
