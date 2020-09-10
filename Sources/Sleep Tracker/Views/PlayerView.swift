//
//  PlayerView.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 8/26/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import SwiftUI
import Combine

protocol PlayerViewDisplayable: ObservableObject {
    var timeLeft: String { get }
    var isRunning: Bool { get }
    func toggleRunning()
    func skipStep()
}

struct PlayerView<T: PlayerViewDisplayable>: View {

    @ObservedObject var model: T

    var body: some View {
        VStack {
            Spacer()
            Text(model.timeLeft)
                .padding()
                .colorInvert()
            HStack {
                Button(action: self.model.toggleRunning) {
                    Image(systemName: self.model.isRunning ? "pause" : "play")
                        .font(.system(size: 30))
                }
            }
            Divider()
                .padding()
            Button(action: model.skipStep) {
                Text("Skip")
            }
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(model: RelaxingSoundStep(kind: .relaxingSound, duration: 5))
    }
}
