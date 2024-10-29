//
//  SpeechSenthesizer.swift
//  AICompanion
//
//  Created by Артур Кулик on 27.10.2024.
//

import Foundation
import AVFoundation

class SpeechSenthesizer {
    let sinthesizer = AVSpeechSynthesizer()
    let audioSession = AVAudioSession.sharedInstance()
    
    func speech(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ru_RU")
        try! audioSession.setCategory(.soloAmbient)
        sinthesizer.speak(utterance)
    }
}
