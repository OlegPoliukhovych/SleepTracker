//
//  SleepSessionContainer.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 8/23/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import SwiftUI

struct SleepSessionContainer: View {

    @Binding var isRunning: Bool
    @ObservedObject var model: SleepSession

    var body: some View {
        VStack {
            if self.model.isAlarmFired {
                AlarmFiredView(shouldClose: self.$isRunning)
            } else {
                HStack() {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.isRunning.toggle()
                        }
                    }) {
                        Image(systemName: "xmark")
                    }
                    .accentColor(Color.text)
                    .padding()
                }
                Spacer()
                GeometryReader { geometry in
                    VStack {
                        PlayerView(model: self.model.currentStepViewModel)
                            .frame(height: geometry.size.height * 0.75)
                    }
                }
                Spacer()
            }
        }
        .padding()
        .onReceive(model.$isRunning) { self.isRunning = $0 }
    }
}

struct SleepSessionContainer_Previews: PreviewProvider {
    static var previews: some View {
        SleepSessionContainer(isRunning: Binding<Bool>.constant(true),
                              model: try! SleepSession(steps: [
                                  SessionStepBaseModel(),
                                  SessionStepBaseModel()
                              ])!)
    }
}
