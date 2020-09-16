//
//  PlayerView.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 8/26/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import SwiftUI

protocol PlayerViewDisplayable: ObservableObject {
    var title: String { get }
    var isRunning: Bool { get }
    func toggleRunning()
    func skipItem()
}

struct PlayerView<T: PlayerViewDisplayable>: View {

    @ObservedObject var model: T

    var body: some View {
        VStack {
            Spacer()
            Text(model.title)
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
