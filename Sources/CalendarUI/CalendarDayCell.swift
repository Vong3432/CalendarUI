//
//  SwiftUIView.swift
//  
//
//  Created by Vong Nyuksoon on 27/06/2022.
//

import SwiftUI

/// This is a custom UI for the Calendar's Cell.
public struct CalendarDayCell: View {
    let calendarDay: CalendarDay
    let config: CalendarCellsStyleConfiguration
    
    public init(calendarDay: CalendarDay, config: CalendarCellsStyleConfiguration) {
        self.calendarDay = calendarDay
        self.config = config
    }
    
    public var body: some View {
        VStack(alignment: .center) {
            Text("\(calendarDay.day)")
                .font(.caption)
                .opacity(calendarDay.isCurrentMonth ? 1 : 0.5)
            
            Circle()
                .fill(calendarDay.isToday ? config.colorForTodayCell : config.colorForTodayCell.opacity(0))
                .frame(width: 5, height: 5)
        }.frame(maxWidth: .infinity)
    }
}

struct CalendarDayCell_Previews: PreviewProvider {
    static var previews: some View {
        CalendarDayCell(calendarDay: .init(day: 1, month: 7, year: 2022, isCurrentMonth: false), config: .original)
    }
}
