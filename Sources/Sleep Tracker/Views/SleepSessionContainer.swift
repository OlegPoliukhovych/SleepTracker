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
            view(model: model.currentStep)
            Spacer()
        }
        .padding()
        .onReceive(model.$isRunning) { self.isRunning = $0 }
    }

    func view(model: SessionStep) -> some View {

        // TODO: Provide actual view for each step
        switch model.kind {
        case .relaxingSound,
             .noiseRecording,
             .alarm:
            return AnyView(
                VStack {
                    Text(model.kind.description)
                        .foregroundColor(Color.text)
                        .padding(.bottom, 16)
                    Button(action: {
                        withAnimation {
                            model.next()
                        }
                    },
                           label: {
                            Text("skip")
                    })
                }
            )
        }
    }
}

struct SleepSessionContainer_Previews: PreviewProvider {
    static var previews: some View {
        SleepSessionContainer(isRunning: Binding<Bool>.constant(true),
                              model: try! SleepSession(steps: [
                                  SessionStepModel(kind: .relaxingSound),
                                  SessionStepModel(kind: .noiseRecording)
                              ])!)
    }
}
