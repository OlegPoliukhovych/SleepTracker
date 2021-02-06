//
//  Array+Extensions.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 2/6/21.
//  Copyright © 2021 Oleg Poliukhovych. All rights reserved.
//

import Foundation

public extension Array {

    /// Returns first element of provided Type if it is contained in the array
    ///
    /// May be useful as a shortcut for looking up and downcasting element to concrete Type
    ///
    ///     let array: Array<Any> = [1, "two", Void()]
    ///
    ///     if let intValue = array.first(as: Int.self) {
    ///         print(intValue)
    ///     }
    ///     // Prints "1"
    ///
    ///     // So this call
    ///     array
    ///         .first(where: { $0 is Int })
    ///         .map { $0 as! Int }?
    ///
    ///     // Can be simplified as this one
    ///     array.first(as: Int.self)
    ///
    /// - Parameter as: Type to look up
    /// - Returns: first found instance of requested Type
    func first<T>(as: T.Type) -> T? {
        self.first { $0 is T } as? T
    }
}
