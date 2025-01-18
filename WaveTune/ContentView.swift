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
                Text("60s").tag(60.0)
                Text("120s").tag(120.0)
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
        .onAppear {
            // Ensure microphone permission is requested
            print( " Ui appeared")
            
        }
    }
}

#Preview {
    ContentView()
}
