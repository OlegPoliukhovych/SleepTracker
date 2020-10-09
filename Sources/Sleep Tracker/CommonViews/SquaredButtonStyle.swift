//
//  SquaredButtonStyle.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 10/7/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import SwiftUI

struct SquaredButtonStyle: ButtonStyle {

    private let disabled: Bool

    init(disabled: Bool = false) {
        self.disabled = disabled
    }

    func makeBody(configuration: Configuration) -> some View {

        configuration.label
            .frame(minWidth: 80, maxHeight: 50, alignment: .center)
            .foregroundColor(configuration.isPressed ? Color.white.opacity(0.25) : .white)
            .background(Color.button)
            .cornerRadius(10)
            .padding(1)
            .opacity(disabled ? 0.5 : 1)
    }
}
