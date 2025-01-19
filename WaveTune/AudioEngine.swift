import AVFoundation

class AudioEngine {
    private var audioEngine: AVAudioEngine
    private var player: AVAudioPlayerNode
    private var mixer: AVAudioMixerNode
    private var displayLink: CADisplayLink?
    private var startTime: TimeInterval = 0
    private var currentDuration: Double = 0
    private var currentLowFreq: Double = 20.0
    private var currentHighFreq: Double = 20000.0
    private var frequencyCallback: ((Double) -> Void)?
    
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
    
    @objc private func updateFrequencyDisplay() {
        guard let callback = frequencyCallback else { return }
        let elapsed = CACurrentMediaTime() - startTime
        let progress = elapsed / currentDuration
        
        if progress <= 1.0 {
            let frequency = currentLowFreq + ( currentHighFreq - currentLowFreq ) * Double(progress)
            callback(frequency)
        }
    }
    
    func playSineWaveSweep(
        duration: Double,
        lowFrequency: Double = 20.0,
        highFrequency: Double = 20000.0,
        frequencyUpdate: @escaping (Double) -> Void,
        completion: @escaping () -> Void
    ) {
        currentDuration = duration
        currentLowFreq = lowFrequency
        currentHighFreq = highFrequency
        frequencyCallback = frequencyUpdate
        
        let sampleRate = 48000.0
        let silenceDuration = 0.025 // 25ms silence padding
        
        let silenceSamples = Int(silenceDuration * sampleRate)
        let sweepSamples = Int(duration * sampleRate)
        let totalSamples = sweepSamples + (2 * silenceSamples)
        
        let buffer = AVAudioPCMBuffer(pcmFormat: mixer.outputFormat(forBus: 0),
                                    frameCapacity: AVAudioFrameCount(totalSamples))!
        buffer.frameLength = AVAudioFrameCount(totalSamples)
        
        let channelData = buffer.floatChannelData?[0]
        
        // Add initial silence
        for i in 0..<silenceSamples {
            channelData?[i] = 0.0
        }
        
        // Generate sweep
        for i in 0..<sweepSamples {
            let time = Double(i) / sampleRate
            let progress = time / duration
            let frequency = lowFrequency + (highFrequency - lowFrequency) * progress  // Linear sweep
            let value = sin(2 * .pi * frequency * time)
            channelData?[i + silenceSamples] = Float(value)
        }
        
        // Add ending silence
        for i in 0..<silenceSamples {
            channelData?[i + silenceSamples + sweepSamples] = 0.0
        }
        
        // Setup display link for frequency updates
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrequencyDisplay))
        displayLink?.add(to: .main, forMode: .common)
        startTime = CACurrentMediaTime()
        
        player.scheduleBuffer(buffer, at: nil, options: []) {
            DispatchQueue.main.async {
                self.displayLink?.invalidate()
                self.displayLink = nil
                self.frequencyCallback = nil
                completion()
            }
        }
        
        player.play()
    }
}
