//
//  Int.swift
//  Productab
//
//  Created by Marwa Awad on 29.11.2025.
//

import Foundation

extension Int {
    func formatNumber() -> String {
        if self >= 1000000 {
            return String(format: "%.1fM", Double(self) / 1000000.0)
        } else if self >= 1000 {
            return String(format: "%.1fK", Double(self) / 1000.0)
        } else {
            return "\(self)"
        }
    }
}
