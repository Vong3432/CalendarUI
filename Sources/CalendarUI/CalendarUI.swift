import SwiftUI

/// This is a custom UI for the Calendar.
@available(iOS 14, *)
public struct CalendarUI: View {
    @Namespace private var animation
    @StateObject private var manager: CalendarManager
    
    private let isExpandable: Bool
    @State private var showFirstRow = true
    @State private var cellOpacity = 1.0
    @State private var iconOpacity = 1.0
    @State private var cellOffsetY = 0.0
    
    private var calendarLabelsStyle: CalendarLabelsStyleConfiguration
    private var calendarCellsStyle: CalendarCellsStyleConfiguration
    
    private let columns = [Int](repeating: 0, count: 7)
        .map { _ in GridItem(.flexible()) }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            weekdaysSymbols
            if showFirstRow && isExpandable {
                firstCellCalendarView
            } else {
                expandedCalendarView
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func onSwiping() -> some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                DispatchQueue.main.async {
                    manager.draggingX = (value.location.x -  value.startLocation.x) * 0.24
                }
            }
            .onEnded { value in
                if value.startLocation.x > value.location.x {
                    // swipe left
                    manager.change(.month, to: .next)
                } else {
                    // swipe right
                    manager.change(.month, to: .prev)
                }
                
            }
    }
}

@available(iOS 14, *)
struct CalendarUI_Previews: PreviewProvider {
    private static var calendarCellStyle: CalendarCellsStyleConfiguration {
        var config = CalendarCellsStyleConfiguration()
        config.colorForTodayCell = .green
        
        return config
    }
    
    private static var calendarLabelsStyle: CalendarLabelsStyleConfiguration {
        var config = CalendarLabelsStyleConfiguration()
        config.dayOfWeekColor = .gray
        
        return config
    }
    
    static var previews: some View {
        CalendarUI(
            initialDate: nil,
            isExpandable: true,
            calendarLabelsStyle: calendarLabelsStyle,
            calendarCellsStyle: calendarCellStyle
        ).customTint(.red)
    }
}

@available(iOS 14, *)
extension CalendarUI {
    
    /// Create an instance of CalendarUI view
    ///
    /// - Parameters:
    ///   - initialDate: The initial Date to show at the first load. Default value is Date.now()
    ///   - isExpandable: Whether the calendar can be fold/unfolded. Default value is false.
    ///   - calendarLabelsStyle: Configure calendar labels styling options. Default value is ``CalendarLabelsStyleConfiguration/original``
    ///   - calendarCellsStyle: Configure calendar cells styling options. Default value is ``CalendarCellsStyleConfiguration/original``
    public init(
        initialDate: Binding<Date>? = nil,
        isExpandable: Bool? = false,
        calendarLabelsStyle: CalendarLabelsStyleConfiguration? = nil,
        calendarCellsStyle: CalendarCellsStyleConfiguration? = nil
    ) {
        self.calendarLabelsStyle = calendarLabelsStyle ?? .original
        self.calendarCellsStyle = calendarCellsStyle ?? .original
        self.isExpandable = isExpandable ?? false
        
        self._manager = StateObject(wrappedValue: CalendarManager(currentDate: initialDate?.wrappedValue ?? Date()))
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(manager.currentMonth)")
                    .font(.largeTitle)
                    .offset(x: 0, y: manager.dragFinished ? 0 : -10)
                    .opacity(manager.dragFinished ? 1.0 : 0.0)
                Text(String(manager.currentYear))
                    .font(.body)
            }
            
            Spacer()
            
            Button {
                manager.change(.month, to: .prev)
            } label: {
                Image(systemName: "chevron.left")
                    .padding()
            }
            
            Button {
                manager.change(.month, to: .next)
            } label: {
                Image(systemName: "chevron.right")
                    .padding()
            }
        }
    }
    
    private var weekdaysSymbols: some View {
        GeometryReader { geo in
            LazyVGrid(
                columns: columns,
                alignment: .leading,
                spacing: 0.0
            ) {
                ForEach(manager.weekdays, id: \.self) { weekday in
                    Text(weekday.uppercased())
                        .font(.caption)
                        .foregroundColor(calendarLabelsStyle.dayOfWeekColor)
                        .frame(width: geo.size.width / 8, height: 50)
                }
            }
            Spacer()
        }.frame(height: 30)
    }
    
    private var firstCellCalendarView: some View {
        HStack(alignment: .center) {
            GeometryReader { geo in
                VStack(alignment: .leading) {
                    LazyVGrid(
                        columns: columns,
                        alignment: .leading,
                        spacing: 0.0
                    ) {
                        if !manager.daysInMonth.isEmpty {
                            ForEach(0..<(manager.COLUMNS_PER_ROW), id: \.self) { i in
                                CalendarDayCell(
                                    calendarDay: manager.daysInMonth[i],
                                    config: calendarCellsStyle
                                )
                                    .frame(width: geo.size.width / 8, height: 50)
                                    .fixedSize()
                            }
                            .offset(x: 0, y: cellOffsetY)
                            .opacity(cellOpacity)
                        }
                    }
                    .offset(x: manager.draggingX, y: 0)
                    .opacity(manager.draggingX == 0 ? 1 : 1 - (0.015 * abs(manager.draggingX)))
                    .gesture(onSwiping())
                    
                    Button {
                        toggleCalendarView()
                    } label: {
                        Label("Expand", systemImage: "chevron.down")
                    }
                    .customTint(.secondary)
                    .frame(width: geo.size.width, alignment: .center)
                    .opacity(iconOpacity)
                }
            }
            .frame(height: 50)
        }
    }
    
    private var expandedCalendarView: some View {
        HStack(alignment: .center) {
            GeometryReader { geo in
                VStack(alignment: .leading) {
                    LazyVGrid(
                        columns: columns,
                        alignment: .leading,
                        spacing: 0.0
                    ) {
                        ForEach(manager.daysInMonth) { calendarDay in
                            CalendarDayCell(
                                calendarDay: calendarDay,
                                config: calendarCellsStyle
                            )
                                .frame(width: geo.size.width / 8, height: 50)
                                .fixedSize()
                        }
                        .offset(x: 0, y: cellOffsetY)
                        .opacity(cellOpacity)
                        
                        if isExpandable {
                            Button {
                                toggleCalendarView()
                            } label: {
                                Label("Hide", systemImage: "chevron.up")
                                    .padding([.top, .leading])
                            }
                            .customTint(.secondary)
                            .frame(width: geo.size.width, alignment: .center)
                            .opacity(iconOpacity)
                        }
                    }
                    .offset(x: manager.draggingX, y: 0)
                    .opacity(manager.draggingX == 0 ? 1 : 1 - (0.015 * abs(manager.draggingX)))
                    .gesture(onSwiping())
                }
            }
            .frame(height: 50)
        }
    }
    
    private func toggleCalendarView() {
        cellOpacity = 0.05
        iconOpacity = 0.05
        
        // If now cells is folded (showFirstRow == true), makes the cell slide from top. Otherwise, slide from bottom.
        cellOffsetY = showFirstRow ? -10 : 10
        
        withAnimation {
            showFirstRow.toggle()
        }
        
        withAnimation(.spring(
            response: 0.25,
            dampingFraction: 0.75,
            blendDuration: 0.25
        ).delay(0.25)) {
            cellOffsetY = 0.0
            cellOpacity = 1.0
        }
        
        withAnimation(.linear.delay(0.5)) {
            iconOpacity = 1.0
        }
    }
}
