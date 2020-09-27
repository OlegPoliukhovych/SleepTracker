//
//  ContentView.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 7/25/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import SwiftUI

struct CheckButtonStyle: ButtonStyle {

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

struct ContentView: View {

    @ObservedObject private var model = SessionSetup()
    @State private var isSessionRunning = false

    var body: some View {
        ZStack {
            view()
        }
        .background(Color.mainBackground.edgesIgnoringSafeArea(.all))
    }

    private func view() -> some View {
        if isSessionRunning, let session = model.prepareSession() {
            return AnyView (
                SleepSessionContainer(isRunning: $isSessionRunning, model: session)
                    .transition(.opacity)
            )
        } else {
            return AnyView (
                SessionSetupView(model: model, isSessionRunning: $isSessionRunning)
            )
        }
    }
}

struct SessionSetupView: View {

    @ObservedObject var model = SessionSetup()

    @State private var relaxingSoundExtended = false
    @State private var alarmExtended = false
    @Binding var isSessionRunning: Bool

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {

                ContainerView {
                    VStack {
                        SettingOptionSelectableView(model: model.relaxing,
                                                    selected: $relaxingSoundExtended)
                        if relaxingSoundExtended {
                            OptionSelectionView(model: model.relaxing,
                                                  selected: $relaxingSoundExtended)
                        }
                    }
                }

                ContainerView {
                    SettingView(model: model.noiseTracking)
                }

                ContainerView {
                    VStack {
                        SettingOptionSelectableView(model: model.alarm, selected: $alarmExtended)
                        if alarmExtended {
                            if #available(iOS 14.0, *) {
                                DatePicker("", selection: $model.alarm.value, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                            } else {
                                DatePicker("", selection: $model.alarm.value, displayedComponents: .hourAndMinute)
                            }
                        }
                    }
                }

                Button(action: {
                    withAnimation {
                        self.isSessionRunning = true
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Start")
                        Spacer()
                    }
                }
                .disabled(!model.isReadyToStart)
                .buttonStyle(CheckButtonStyle(disabled: !model.isReadyToStart))
                .padding(.top, 32)
            }
            .padding()
            Spacer()
        }
        .animation(Animation.spring(), value: relaxingSoundExtended || alarmExtended)
    }
}

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

struct SettingView<T: SettingDisplayable>: View {

    @ObservedObject var model: T

    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    self.model.enabled.toggle()
                }) {
                    Image(systemName: model.enabled ? "checkmark.circle" : "circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .accentColor(Color.text)
                .padding()
                Spacer()
            }
            HStack {
                Spacer()
                Text(model.title)
                    .foregroundColor(Color.text)
                Spacer()
            }
        }
        .frame(height: 50)
    }
}

protocol SettingDisplayable: ObservableObject {
    var enabled: Bool { get set }
    var title: String { get }
}

protocol SettingOptionable: ObservableObject {
    var imageName: String? { get }
    var valueDescription: String { get }
}

protocol OptionSelectable: ObservableObject {
    var values: [String] { get }
    func selectValue(at index: Int)
}

struct SettingOptionSelectableView<T: SettingDisplayable & SettingOptionable>: View {

    @ObservedObject var model: T
    @Binding var selected: Bool

    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                SettingView(model: model)
                Button(action: {
                    withAnimation {
                        self.selected.toggle()
                    }
                }) {
                    VStack {
                        // Currently iOS 13 SDK don't allow to unwrap otionals in "if let" statement, so check for nil and then force unwrap
                        // after switching to iOS 14 SDK (Xcode 12) this issue will be fixed
                        if model.imageName != nil {
                            Image(systemName: model.imageName!)
                        }
                        Text(self.model.valueDescription)
                            .font(.system(size: 12))
                    }
                }
                .buttonStyle(CheckButtonStyle())
            }
        }
    }
}

struct OptionSelectionView<T: OptionSelectable>: View {

    @ObservedObject var model: T
    @Binding var selected: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {

                ForEach(model.values.indices) { optionIndex in
                    Button(action: {
                        self.model.selectValue(at: optionIndex)
                        withAnimation {
                            self.selected.toggle()
                        }
                    }) {
                        Text(self.model.values[optionIndex])
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                    }
                    .buttonStyle(CheckButtonStyle())
                }
            }
        }
        .frame(height: 50, alignment: .leading)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
