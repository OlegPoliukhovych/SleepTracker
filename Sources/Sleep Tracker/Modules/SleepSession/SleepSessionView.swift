//
//  SleepSessionView.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 8/23/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import SwiftUI

struct SleepSessionView: View {

    @Binding var isRunning: Bool
    @ObservedObject var model: SleepSession
    @State private var exitAlertEnabled = false

    var body: some View {
        VStack {
            if model.isAlarmFired {
                AlarmFiredView(shouldClose: $isRunning)
            } else {
                HStack() {
                    Spacer()
                    Button(action: {
                        exitAlertEnabled.toggle()
                    }) {
                        Image(systemName: "xmark")
                    }
                    .alert(isPresented: $exitAlertEnabled) {
                        Alert(title: Text("Are you sure you want to leave session?"),
                              primaryButton: .cancel(Text("No")),
                              secondaryButton: .default(Text("Yes"),
                                                        action: {
                                                            withAnimation {
                                                                self.model.cancel()
                                                            }
                                                        })
                        )
                    }
                    .accentColor(Color.text)
                    .padding()

                }
                Spacer()
                GeometryReader { geometry in
                    VStack {
                        AnyView(
                            self.model.currentStepViewModel.map {
                                PlayerView(model: $0)
                                    .frame(height: geometry.size.height * 0.75)
                            })
                    }
                }
                Spacer()
            }
        }
        .padding()
        .onReceive(model.$isRunning.dropFirst(), perform: { self.isRunning = $0 })
        .onAppear {
            model.start()
        }
    }
}

struct SleepSessionView_Previews: PreviewProvider {
    static var previews: some View {
        SleepSessionView(isRunning: Binding<Bool>.constant(true),
                         model: try! SleepSession(stepsInfo: [.relaxing(300),
                                                              .recording(timeout: nil),
                                                              .alarm(Date())])!)
    }
}
