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
    @State private var lowFrequency: String = "20"
    @State private var highFrequency: String = "20000"
    @State private var currentFrequency: Double = 0
    private let engine = AudioEngine()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sine Wave Generator")
                .font(.title)
                .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Low Frequency (Hz)")
                        .font(.caption)
                    TextField("Low Frequency", text: $lowFrequency)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading) {
                    Text("High Frequency (Hz)")
                        .font(.caption)
                    TextField("High Frequency", text: $highFrequency)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
            .padding()
            
            if isPlaying {
                Text("Current Frequency: \(String(format: "%.1f Hz", currentFrequency))")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
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
                    let lowFreq = Double(lowFrequency) ?? 20.0
                    let highFreq = Double(highFrequency) ?? 20000.0
                    
                    engine.playSineWaveSweep(
                        duration: duration,
                        lowFrequency: lowFreq,
                        highFrequency: highFreq
                    ) { frequency in
                        currentFrequency = frequency
                    } completion: {
                        isPlaying = false
                        currentFrequency = 0
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
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                         to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    ContentView()
}
