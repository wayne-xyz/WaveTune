//
//  ContentView.swift
//  WaveTune
//
//  Created by Rongwei Ji on 1/17/25.
//

import SwiftUI
import SwiftData
import AVFoundation

struct ContentView: View {
    var body: some View {
        TabView {
            SineWaveView()
                .tabItem {
                    Label("Sine Wave", systemImage: "waveform.path")
                }
            
            Text("Constant Wave")
                .tabItem {
                    Label("Constant", systemImage: "waveform")
                }
            
            Text("Pulse Wave")
                .tabItem {
                    Label("Pulse", systemImage: "waveform.path.ecg")
                }
        }
    }
}

struct SineWaveView: View {
    @State private var isPlaying = false
    @State private var duration: Double = 5
    private let engine = AudioEngine()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sine Wave Generator")
                .font(.title)
                .padding()
            
            Picker("Duration", selection: $duration) {
                Text("5s").tag(5.0)
                Text("10s").tag(10.0)
                Text("15s").tag(15.0)
                Text("20s").tag(20.0)
            }
            .pickerStyle(.segmented)
            .padding()
            
            Button(action: {
                if !isPlaying {
                    isPlaying = true
                    engine.playSineWaveSweep(duration: duration) {
                        isPlaying = false
                    }
                }
            }) {
                Text(isPlaying ? "Playing..." : "Start")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(isPlaying ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isPlaying)
            
            Spacer()
        }
    }
}

class AudioEngine {
    private var audioEngine: AVAudioEngine
    private var player: AVAudioPlayerNode
    private var mixer: AVAudioMixerNode
    
    init() {
        audioEngine = AVAudioEngine()
        player = AVAudioPlayerNode()
        mixer = audioEngine.mainMixerNode
        
        audioEngine.attach(player)
        audioEngine.connect(player, to: mixer, format: mixer.outputFormat(forBus: 0))
        
        try? audioEngine.start()
    }
    
    func playSineWaveSweep(duration: Double, completion: @escaping () -> Void) {
        let sampleRate = 44100.0
        let startFrequency: Double = 20.0  // Start at 20 Hz
        let endFrequency: Double = 2000.0  // End at 2 kHz
        
        let numberOfSamples = Int(duration * sampleRate)
        var audioData = [Float]()
        
        for i in 0..<numberOfSamples {
            let progress = Double(i) / Double(numberOfSamples)
            let time = Double(i) / sampleRate
            
            // First half: frequency goes up
            // Second half: frequency goes down
            let frequency = progress < 0.5 ?
                startFrequency + (endFrequency - startFrequency) * (progress * 2) :
                endFrequency - (endFrequency - startFrequency) * ((progress - 0.5) * 2)
            
            let value = sin(2.0 * .pi * frequency * time)
            audioData.append(Float(value))
        }
        
        let buffer = AVAudioPCMBuffer(pcmFormat: mixer.outputFormat(forBus: 0),
                                    frameCapacity: AVAudioFrameCount(numberOfSamples))!
        buffer.frameLength = AVAudioFrameCount(numberOfSamples)
        
        let channelData = buffer.floatChannelData?[0]
        for i in 0..<numberOfSamples {
            channelData?[i] = audioData[i]
        }
        
        player.scheduleBuffer(buffer, at: nil, options: .interrupts) {
            DispatchQueue.main.async {
                completion()
            }
        }
        player.play()
    }
}

#Preview {
    ContentView()
}
