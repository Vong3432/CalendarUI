//
//  File.swift
//  
//
//  Created by Vong Nyuksoon on 27/06/2022.
//

import Foundation

public extension DateFormatter {
    static let current: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }()
}
