import SwiftUI

@available(iOS 14, *)
extension CalendarUI {
    public init(
        initialDate: Binding<Date>? = nil,
        calendarLabelsStyle: CalendarLabelsStyleConfiguration? = nil,
        calendarCellsStyle: CalendarCellsStyleConfiguration? = nil
    ) {
        self.calendarLabelsStyle = calendarLabelsStyle ?? .original
        self.calendarCellsStyle = calendarCellsStyle ?? .original
        
        self._manager = StateObject(wrappedValue: CalendarManager(currentDate: initialDate?.wrappedValue ?? Date()))
    }
}

/// This is a custom UI for the Calendar.
@available(iOS 14, *)
public struct CalendarUI: View {
    @Namespace private var animation
    @StateObject private var manager: CalendarManager
    
    private var calendarLabelsStyle: CalendarLabelsStyleConfiguration
    private var calendarCellsStyle: CalendarCellsStyleConfiguration
    
    private let columns = [Int](repeating: 0, count: 7)
        .map { _ in GridItem(.flexible()) }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
            
            GeometryReader { geo in
                VStack(alignment: .leading) {
                    HStack {
                        ForEach(manager.weekdays, id: \.self) { weekday in
                            Text(weekday.uppercased())
                                .font(.caption)
                                .foregroundColor(calendarLabelsStyle.dayOfWeekColor)
                                .frame(width: geo.size.width / 8)
                        }
                    }
                    
                    LazyVGrid(columns: columns) {
                        ForEach(manager.daysInMonth) { calendarDay in
                            CalendarDayCell(
                                calendarDay: calendarDay,
                                config: calendarCellsStyle
                            )
                                .frame(width: geo.size.width / 8, height: 50)
                                .fixedSize()
                        }
                    }
                    .offset(x: manager.draggingX, y: 0)
                    .opacity(manager.draggingX == 0 ? 1 : 1 - (0.015 * abs(manager.draggingX)))
                    .gesture(
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
                    )
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
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
            calendarLabelsStyle: calendarLabelsStyle,
            calendarCellsStyle: calendarCellStyle
        ).customTint(.red)
    }
}
