//
//  Date.swift
//  Roadmap
//
//  Created by Onur Bas on 29/02/2024.
//

import Foundation

extension Date {
    func formatRelativeTime() -> String {
        let date = self

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let string = formatter.localizedString(for: date, relativeTo: Date())

        return string
    }
}
