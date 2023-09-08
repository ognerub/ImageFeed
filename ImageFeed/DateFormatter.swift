//
//  DateFormatter.swift
//  ImageFeed
//
//  Created by Admin on 08.09.2023.
//

import Foundation

var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()

extension Date {
    var dateTimeString: String { dateFormatter.string(from: self)}
}

extension String {
    var dateTimeString: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: self)
    }
}
