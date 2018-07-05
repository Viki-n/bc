//
//  sound.swift
//  bc
//
//  Created by Viki on 30/04/2018.
//  Copyright © 2018 Viki. All rights reserved.
//
// credits: https://gist.github.com/rgcottrell/5b876d9c5eea4c9e411c

import AVFoundation
import Foundation

func MakeScaledSound(Tone:Double){
    if((State.CurrentSubject.Feedback == .ELM) &&//Feedback should be given
        ((State.SubjectName == "unknown") || //default observer -- debug reasons
            (State.currentTrial.TrialNumber > State.FirstAndThirdTest && //not within first test
                State.currentTrial.TrialNumber <= State.FirstAndThirdTest + State.SecondTest))){//not after second test
        Constants.AudioPlayer.play(Float32(440*pow(2, Tone)), modulatorFrequency: 600, modulatorAmplitude: 0, duration: 0.8)
    }
    
}
// The single FM synthesizer instance.
let gFMSynthesizer: FMSynthesizer = FMSynthesizer()

class FMSynthesizer {
    
    // The maximum number of audio buffers in flight. Setting to two allows one
    // buffer to be played while the next is being written.
    var kInFlightAudioBuffers: Int = 2
    
    // The number of audio samples per buffer. A lower value reduces latency for
    // changes but requires more processing but increases the risk of being unable
    // to fill the buffers in time. A setting of 1024 represents about 23ms of
    // samples.
    let kSamplesPerBuffer: AVAudioFrameCount = 1024
    
    // The audio engine manages the sound system.
    let audioEngine: AVAudioEngine = AVAudioEngine()
    
    // The player node schedules the playback of the audio buffers.
    let playerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    
    // Use standard non-interleaved PCM audio.
    let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)
    
    // A circular queue of audio buffers.
    var audioBuffers: [AVAudioPCMBuffer] = [AVAudioPCMBuffer]()
    
    // The index of the next buffer to fill.
    var bufferIndex: Int = 0
    
    // The dispatch queue to render audio samples.
    let audioQueue: DispatchQueue = DispatchQueue(label: "FMSynthesizerQueue", attributes: [])
    
    // A semaphore to gate the number of buffers processed.
    let audioSemaphore: DispatchSemaphore
    
    class func sharedSynth() -> FMSynthesizer {
        return gFMSynthesizer
    }
    
    public init() {
        // init the semaphore
        audioSemaphore = DispatchSemaphore(value: kInFlightAudioBuffers)
        
        // Create a pool of audio buffers.
        audioBuffers = [AVAudioPCMBuffer](repeating: AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: UInt32(kSamplesPerBuffer))!, count: 2)
        
        // Attach and connect the player node.
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFormat)
        
        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine didn't start")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(FMSynthesizer.audioEngineConfigurationChange(_:)), name: NSNotification.Name.AVAudioEngineConfigurationChange, object: audioEngine)
    }
    
    func play(_ carrierFrequency: Float32, modulatorFrequency: Float32, modulatorAmplitude: Float32, duration: Double) {
        let unitVelocity = Float32(2.0 * Double.pi / (audioFormat?.sampleRate)!)
        let carrierVelocity = carrierFrequency * unitVelocity
        let modulatorVelocity = modulatorFrequency * unitVelocity
        audioQueue.async {
            var sampleTime: Float32 = 0
            var i=0
            while Double(i)<duration*1000/23 { //Length of one buffer is about 23 ms
                i += 1
                // Wait for a buffer to become available.
                _ = self.audioSemaphore.wait(timeout: DispatchTime.distantFuture)
                //The part where you actually generate the sound
                // Fill the buffer with new samples.
                let audioBuffer = self.audioBuffers[self.bufferIndex]
                let leftChannel = audioBuffer.floatChannelData?[0]
                let rightChannel = audioBuffer.floatChannelData?[1]
                if(i<=Constants.BuffersUntilFullVolume){//first iteration, need the sound to increase in volume gradually
                    for sampleIndex in 0 ..< Int(self.kSamplesPerBuffer) {
                        let sample = sin(carrierVelocity * sampleTime + modulatorAmplitude * sin(modulatorVelocity  * sampleTime)) * sqr(sin(Float(sampleTime)/Float(self.kSamplesPerBuffer) / Float(Constants.BuffersUntilFullVolume) * Float(Double.pi) / 2))
                        leftChannel?[sampleIndex] = sample
                        rightChannel?[sampleIndex] = sample
                        sampleTime = sampleTime + 1.0
                    }
                }else if (Double(i)>=duration*1000/23) {//last iteration, need to decrease the volume gradually
                    for sampleIndex in 0 ..< Int(self.kSamplesPerBuffer) {
                        let sample = sin(carrierVelocity * sampleTime + modulatorAmplitude * sin(modulatorVelocity  * sampleTime))*(1-Float(sampleIndex)/Float(self.kSamplesPerBuffer))
                        leftChannel?[sampleIndex] = sample
                        rightChannel?[sampleIndex] = sample
                        sampleTime = sampleTime + 1.0
                    }
                } else { //second to pre-last iteration
                    for sampleIndex in 0 ..< Int(self.kSamplesPerBuffer) {
                        let sample = sin(carrierVelocity * sampleTime + modulatorAmplitude * sin(modulatorVelocity  * sampleTime))
                        leftChannel?[sampleIndex] = sample
                        rightChannel?[sampleIndex] = sample
                        sampleTime = sampleTime + 1.0
                    }
                }
                audioBuffer.frameLength = self.kSamplesPerBuffer
                
                // Schedule the buffer for playback and release it for reuse after
                // playback has finished.
                self.playerNode.scheduleBuffer(audioBuffer) {
                    self.audioSemaphore.signal()
                    return
                }
                
                self.bufferIndex = (self.bufferIndex + 1) % self.audioBuffers.count
            }
        }
        
        playerNode.pan = 0.8
        playerNode.play()
    }
    
    @objc  func audioEngineConfigurationChange(_ notification: Notification) -> Void {
        NSLog("Audio engine configuration change: \(notification)")
    }
}
