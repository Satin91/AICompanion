//
//  Data.swift
//  AICompanion
//
//  Created by Артур Кулик on 22.10.2024.
//

import Foundation

extension Data {
    
    var readableJson: String {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            if let prettyPrintedString = String(data: jsonData, encoding: .utf8) {
                return prettyPrintedString
            }
        } catch {
            print("Error pretty print \(error)")
        }
        return "Can't get pretty JSON"
    }
}
