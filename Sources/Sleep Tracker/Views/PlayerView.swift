//
//  PlayerView.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 8/26/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import SwiftUI

protocol PlayerViewDisplayable: ObservableObject {
    var style: PlayerViewControlsStyle { get }
    var title: String { get }
    var isRunning: Bool { get }
    func toggleRunning()
    func skipItem()
}

enum PlayerViewControlsStyle {
    case playback, recording, none
}

struct PlayerView<T: PlayerViewDisplayable>: View {

    @ObservedObject var model: T

    var body: some View {
        VStack {
            Spacer()
            if model.style != .none {
                VStack {
                    Text(self.model.title)
                        .padding()
                        .colorInvert()
                    HStack {
                        Button(action: self.model.toggleRunning) {
                            Image(systemName: self.model.isRunning ? "pause" :
                                self.model.style == .playback ? "play" : "largecircle.fill.circle")
                                .font(.system(size: 30))
                                .foregroundColor(self.model.style == .recording ? Color.red : nil)
                        }
                    }
                }
            }
            Divider()
                .padding()
            Button(action: model.skipItem) {
                Text("Skip")
            }
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(model: PlayerViewModel())
    }
}
