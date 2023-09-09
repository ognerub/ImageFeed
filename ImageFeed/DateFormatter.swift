//
//  DateFormatter.swift
//  ImageFeed
//
//  Created by Admin on 08.09.2023.
//

import Foundation

extension String {
    public func formatISODateString(dateFormat: String) -> String {
        var formatDate = self
        let isoDateFormatter = ISO8601DateFormatter()
        if let date = isoDateFormatter.date(from: self) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            formatDate = dateFormatter.string(from: date)
        }
        return formatDate
    }
}
