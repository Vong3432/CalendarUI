//
//  CalendarManager.swift
//  
//
//  Created by Vong Nyuksoon on 27/06/2022.
//

import Foundation
import UIKit
import SwiftUI

/// This is a utility class where you can use it to create your own Calendar UI without writing the logic by yourself.
@available(iOS 13, *)
public class CalendarManager: ObservableObject {
    
    public let MAX_ROWS = 6
    public let COLUMNS_PER_ROW = 7
    
    @Published private(set) var currentDate = Date()
    @Published private(set) var currentMonth = "January"
    @Published private(set) var currentYear = 2020
    @Published private(set) var weekdays = [String]()
    @Published private(set) var daysInMonth = [CalendarDay]()
    @Published var startAnimating: Bool = false
    
    @Published private(set) var selectedDays = [CalendarDay]()
    
    // animation properties
    @Published var draggingX: Double = 0.0
    @Published private(set) var dragFinished = true
    
    public init(currentDate: Date) {
        
        if Calendar.current.dateComponents(in: .current, from: currentDate).isValidDate {
            // if passed date is valid
            self.currentDate = currentDate
        } else {
            // else, set default date
            self.currentDate = Date()
        }
        
        updateCalendarStat(date: currentDate)
    }
    
    /// Handle UI update logic based on the date
    private func updateCalendarStat(date: Date) {
        /// Get prev date.
        /// ```.day``` does not matter here.
        let prevMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
        let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
        
        // Get components of prev, next and current date
        let dateComponent = Calendar.current.dateComponents(in: .current, from: date)
        let prevComponent = Calendar.current.dateComponents(in: .current, from: prevMonthDate)
        let nextComponent = Calendar.current.dateComponents(in: .current, from: nextMonthDate)
        
        // Get date components based on timezone, year and month
        let components = DateComponents(calendar: .current, timeZone: .init(secondsFromGMT: 0), year: dateComponent.year, month: dateComponent.month)
        let prevComponents = DateComponents(calendar: .current, timeZone: .init(secondsFromGMT: 0), year: prevComponent.year, month: prevComponent.month)
        
        /// Get the date that start with first day only. The month and year is set based on the previous
        /// ``` components ``` variable.
        /// E.g 2022-01-01, 2022-03-01, ...
        let date = Calendar.current.date(from: components)!
        let prevDate = Calendar.current.date(from: prevComponents)!

        // Get total days range
        let totalDaysInCurrentMonth = Calendar.current.range(of: .day, in: .month, for: date)!.count
        let totalDaysInPrevMonth = Calendar.current.range(of: .day, in: .month, for: prevDate)!.count
        
        // Get the first weekday
        let weekday = Calendar.current.component(.weekday, from: date)
        
        // Generate days in current month, year
        var daysInPrevMonth = [CalendarDay]()
        var daysInCurrentMonth = [CalendarDay]()
        var daysInNextMonth = [CalendarDay]()

        if weekday != 1 {
            // Determine how many offsets are required before the first day of the month
            let offsetAtBeginningOfTheMonth = abs(0 - weekday + 2)
            
            daysInPrevMonth = generateCalendarDays(
                from: totalDaysInPrevMonth - offsetAtBeginningOfTheMonth,
                to: totalDaysInPrevMonth + 1,
                month: prevComponent.month!,
                year: prevComponent.year!,
                isCurrentMonth: false
            )
        }
        
        daysInCurrentMonth = generateCalendarDays(
            from: 1,
            to: totalDaysInCurrentMonth + 1,
            month: dateComponent.month!,
            year: dateComponent.year!,
            isCurrentMonth: true
        )
        
        let max = MAX_ROWS * COLUMNS_PER_ROW
        let upperBoundForNextMonth = max - (daysInPrevMonth.count + daysInCurrentMonth.count) + 1
        
        daysInNextMonth = generateCalendarDays(
            from: 1,
            to: upperBoundForNextMonth,
            month: nextComponent.month!,
            year: nextComponent.year!,
            isCurrentMonth: false
        )
        
        DispatchQueue.main.async {
            self.daysInMonth = daysInPrevMonth + daysInCurrentMonth + daysInNextMonth
            self.weekdays = dateComponent.calendar!.shortWeekdaySymbols
            self.currentMonth = dateComponent.month!.toMonthSymbol()
            self.currentYear = dateComponent.year!
            
            withAnimation(.linear) {
                self.draggingX = .zero
            }
            
            withAnimation(.easeOut.delay(0.15)) {
                self.dragFinished = true
            }
        }
        
    }
    
    private func generateCalendarDays(from: Int, to: Int, month: Int, year: Int, isCurrentMonth: Bool) -> [CalendarDay] {
        return (from..<to).map { CalendarDay(
            day: $0,
            month: month,
            year: year,
            isCurrentMonth: isCurrentMonth)
        }
    }
    
    /// Handler for the calendar logic.
    ///
    /// You may call this handler for changing calendar's month, year, etc..
    ///
    /// - parameter component: [Calendar.Component](https://developer.apple.com/documentation/foundation/calendar/component)
    /// - parameter to: ``.next`` or  ``.prev``
    public func change(_ component: Calendar.Component, to control: CalendarControl) {
        dragFinished = false
        
        DispatchQueue.main.async {
            if control == .next {
                self.draggingX = ((UIScreen.main.bounds.width / 2) + self.draggingX) * 1
            } else {
                self.draggingX = ((UIScreen.main.bounds.width / 2) + self.draggingX) * -1
            }
        }
        
        let newDate = Calendar.current.date(byAdding: component, value: control == .next ? 1 : -1, to: currentDate)!
        currentDate = newDate
        updateCalendarStat(date: currentDate)
    }
}

