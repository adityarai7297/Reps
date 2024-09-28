import SwiftUI
import FSCalendar

struct FSCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date?
    let workoutDays: [Date]

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()

        // Customize the calendar appearance
        calendar.appearance.headerTitleColor = UIColor.systemBlue
        calendar.appearance.weekdayTextColor = UIColor.systemBlue
        calendar.appearance.selectionColor = UIColor.systemRed
        calendar.appearance.todayColor = UIColor.systemGreen
        calendar.appearance.titleTodayColor = UIColor.white
        calendar.appearance.titleDefaultColor = UIColor.white

        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator

        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // Only reload data if workoutDays have changed
        if context.coordinator.workoutDays != workoutDays {
            uiView.reloadData()
            context.coordinator.workoutDays = workoutDays
        }

        // Only update selection if the selected date has changed
        if let selectedDate = selectedDate {
            if let currentSelectedDate = uiView.selectedDate {
                if !Calendar.current.isDate(currentSelectedDate, inSameDayAs: selectedDate) {
                    // Disable animations to prevent ghosting
                    UIView.performWithoutAnimation {
                        uiView.select(selectedDate)
                    }
                }
            } else {
                UIView.performWithoutAnimation {
                    uiView.select(selectedDate)
                }
            }
        } else {
            if let currentSelectedDate = uiView.selectedDate {
                UIView.performWithoutAnimation {
                    uiView.deselect(currentSelectedDate)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: FSCalendarView
        var workoutDays: [Date]

        init(_ parent: FSCalendarView) {
            self.parent = parent
            self.workoutDays = parent.workoutDays
        }

        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            if workoutDays.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                return 1
            }
            return 0
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
            if monthPosition != .current {
                calendar.setCurrentPage(date, animated: true)
            }
        }

        func minimumDate(for calendar: FSCalendar) -> Date {
            return Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        }

        func maximumDate(for calendar: FSCalendar) -> Date {
            return Date()
        }

        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            return UIColor.white
        }
    }
}
