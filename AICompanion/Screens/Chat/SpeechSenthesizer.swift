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
    
    func speech(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        sinthesizer.speak(utterance)
    }
}
