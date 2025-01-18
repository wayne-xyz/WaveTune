import AVFoundation

class AudioEngine {
    private var audioEngine: AVAudioEngine
    private var player: AVAudioPlayerNode
    private var mixer: AVAudioMixerNode
    
    init() {
        // Setup Audio Session for both play and record
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
        
        audioEngine = AVAudioEngine()
        player = AVAudioPlayerNode()
        mixer = audioEngine.mainMixerNode
        
        audioEngine.attach(player)
        audioEngine.connect(player, to: mixer, format: mixer.outputFormat(forBus: 0))
        
        try? audioEngine.start()
    }
    
    func playSineWaveSweep(duration: Double, completion: @escaping () -> Void) {
        let sampleRate = 48000.0
        let lowFrequency: Double = 20.0  // Low value 20 Hz
        let highFrequency: Double = 20000.0  // High value 20 kHz
        
        // Calculate total samples for the full duration
        let totalSamples = Int(duration * sampleRate)
        
        // Create single buffer for the full sweep
        let buffer = AVAudioPCMBuffer(pcmFormat: mixer.outputFormat(forBus: 0),
                                    frameCapacity: AVAudioFrameCount(totalSamples))!
        buffer.frameLength = AVAudioFrameCount(totalSamples)
        
        let channelData = buffer.floatChannelData?[0]
        for i in 0..<totalSamples {
            let time = Double(i) / sampleRate
            let progress = time / duration
            let frequency = lowFrequency + (highFrequency - lowFrequency) * progress
            let value = sin(2.0 * .pi * frequency * time)
            channelData?[i] = Float(value)
        }
        
  
        
        // Schedule the single buffer with completion handler
        player.scheduleBuffer(buffer, at: nil, options: []) {
            DispatchQueue.main.async {
                print("Sweep completed")
                completion()
            }
        }
        
        player.play()
    }
    
    

}
