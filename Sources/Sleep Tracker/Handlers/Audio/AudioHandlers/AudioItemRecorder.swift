//
//  AudioItemRecorder.swift
//  Sleep Tracker
//
//  Created by Oleg Poliukhovych on 9/10/20.
//  Copyright © 2020 Oleg Poliukhovych. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

final class AudioItemRecorder: AudioItemHandler {

    private let destination: URL

    private let audioEngine = AVAudioEngine()
    /// Threshold level
    private let averagePowerThreshold: Float = -40

    @Published private var shouldActuallyRecord: Bool = false
    @Published private var outputFile: AVAudioFile? = nil

    private let bufferOutputQueue = DispatchQueue(label: "sleep.recorder.bufferOutput.serial.queue")

    var cancellables = Set<AnyCancellable>()

    init(destination: URL) {
        self.destination = destination
    }

    private func prepareOutputFile() -> AVAudioFile? {

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy-HH:mm:ss"
        let datePathComponent = dateFormatter.string(from: Date())
        let filename = destination.appendingPathComponent("\(datePathComponent).aac")
        return try? AVAudioFile(forWriting: filename, settings: settings)
    }

    // MARK: AudioItemHandler

    func prepare() {

        unowned let _self = self

        /// provide buffer only when it is actually needed - shouldActuallyRecord == true
        let bufferPublisher = audioEngine.record()
            .combineLatest($shouldActuallyRecord)
            .filter { $0.1 }
            .map { $0.0 }
            .subscribe(on: bufferOutputQueue, options: .none)
            .share()

        /// create new file if there is recognizable noise in buffer and output file is not exist
        bufferPublisher
            .combineLatest($outputFile)
            .filter { $0.1 == nil && _self.isSoundLevelRecoznizable(buffer: $0.0) }
            .map { _ in _self.prepareOutputFile() }
            .sink(receiveValue: { _self.outputFile = $0 })
            .store(in: &cancellables)

        /// Close currently used file after 2 seconds of "silence" in audio input
        bufferPublisher
            .combineLatest($outputFile)
            .filter { $0.1 != nil && _self.isSoundLevelRecoznizable(buffer: $0.0) }
            .debounce(for: .seconds(2), scheduler: bufferOutputQueue)
            .sink(receiveValue: { _ in _self.outputFile = nil })
            .store(in: &cancellables)

        /// Write buffer into a file
        bufferPublisher
            .combineLatest($outputFile)
            .filter { $0.1 != nil }
            .sink { buffer, file in
                try? file?.write(from: buffer)
            }
            .store(in: &cancellables)
    }

    func run() {
        guard shouldActuallyRecord else {
            shouldActuallyRecord = true
            return
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    func pause() {
        audioEngine.pause()
        outputFile = nil
    }

    func finish() {
        shouldActuallyRecord = false
        audioEngine.cleanupRecording()
    }

    /// Checking if average power of sample is "hearable" to prevent writing silent samples into the file
    /// - Parameter buffer: buffer of audio samples
    /// - Returns: Bool value indicating if average power of provided samples is high enough to be recognized as hearable noise
    private func isSoundLevelRecoznizable(buffer: AVAudioPCMBuffer) -> Bool {
        guard let channelData = buffer.floatChannelData else { return false }
        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0,
                                           to: Int(buffer.frameLength),
                                           by: buffer.stride)
            .map { channelDataValue[$0] }

        let rms = channelDataValueArray
            .map { $0 * $0 }
            .reduce(0, +) / Float(buffer.frameLength)
        let avgPower = 20 * log10(sqrt(rms))

        return avgPower > averagePowerThreshold
    }

}

extension AVAudioEngine {

    func record() -> AnyPublisher<AVAudioPCMBuffer, Never> {

        Deferred<AnyPublisher<AVAudioPCMBuffer, Never>> { [unowned self] in

            let subject = PassthroughSubject<AVAudioPCMBuffer, Never>()
            self.inputNode.installTap(onBus: 0,
                                      bufferSize: 4096,
                                      format: self.inputNode.outputFormat(forBus: 0)) { buffer, time in
                                        subject.send(buffer)
            }

            self.prepare()
            do {
                try self.start()
            } catch {
                assertionFailure("failed starting recording audio with error: \(error.localizedDescription)")
            }

            return subject
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func cleanupRecording() {
        inputNode.removeTap(onBus: 0)
        stop()
        reset()
    }
}
