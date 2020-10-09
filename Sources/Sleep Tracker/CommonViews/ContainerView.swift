//
//  ContainerView.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 10/7/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import SwiftUI

struct ContainerView<Content: View>: View {

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(Color.elementBackground)
            .clipShape(RoundedRectangle(cornerRadius: 11))
    }
}

struct ContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView { Text("ContainerView placeholder") }
    }
}
