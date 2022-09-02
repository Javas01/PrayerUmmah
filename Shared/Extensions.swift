//
//  Extensions.swift
//  PrayerUmmah
//
//  Created by Jawwaad Sabree on 7/12/22.
//

import SwiftUI

extension View {
    /// Whether the view should be empty.
    /// - Parameter bool: Set to `true` to hide the view (return EmptyView instead). Set to `false` to show the view.
    func isEmpty(_ bool: Bool) -> some View {
        modifier(EmptyModifier(isEmpty: bool))
    }
}

extension Date {
    var display: String {
        self.formatted(
            .dateTime
            .day()
            .month(.wide)
            .weekday(.wide)
            )
    }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}

extension String {
    func getDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter.date(from: self) ?? Date()
    }
}
