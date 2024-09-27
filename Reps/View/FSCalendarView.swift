import SwiftUI
import FSCalendar

struct FSCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date?
    let workoutDays: [Date] // List of dates that have workout data

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()

        // Customize the calendar appearance
        calendar.appearance.headerTitleColor = UIColor.systemBlue
        calendar.appearance.weekdayTextColor = UIColor.systemBlue
        calendar.appearance.selectionColor = UIColor.systemBlue
        calendar.appearance.todayColor = UIColor.systemGray
        calendar.appearance.titleTodayColor = UIColor.white

        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator

        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.reloadData() // Reload calendar when workout days or selected date changes
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: FSCalendarView

        init(_ parent: FSCalendarView) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            // If the date has workouts, return 1 to show an indicator dot
            if parent.workoutDays.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                return 1
            }
            return 0
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            // Update selected date when a date is tapped
            parent.selectedDate = date
        }

        func minimumDate(for calendar: FSCalendar) -> Date {
            // Set the minimum date for the calendar
            return Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        }

        func maximumDate(for calendar: FSCalendar) -> Date {
            // Set the maximum date for the calendar
            return Date()
        }
    }
}
