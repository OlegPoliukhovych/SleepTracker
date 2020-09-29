//
//  AlarmFiredView.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/29/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import SwiftUI

struct AlarmFiredView: View {

    @Binding var shouldClose: Bool

    var body: some View {
        VStack() {
            Spacer()
            Text("Good morning")
                .padding()
            Button("Done") {
                self.shouldClose.toggle()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct AlarmFiredView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmFiredView(shouldClose: Binding<Bool>.constant(false))
    }
}
