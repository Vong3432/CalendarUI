//
//  File.swift
//  
//
//  Created by Vong Nyuksoon on 27/06/2022.
//

import Foundation

public struct CalendarDay: Identifiable {
    public let id = UUID()
    public let day: Int
    public let month: Int
    public let year: Int
    public let isCurrentMonth: Bool
    
    public var toDate: Date {
        var component = DateComponents()
        component.year = year
        component.month = month
        component.day = day
        component.timeZone = .init(secondsFromGMT: 0)
        
        return Calendar.current.date(from: component) ?? Date()
    }
    
    public var isToday: Bool {
        Calendar.current.isDateInToday(toDate)
    }
}
