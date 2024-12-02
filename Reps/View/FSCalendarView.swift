import SwiftUI
import FSCalendar

struct FSCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date?
    let workoutData: [Date: Int] // Mapping from date to number of sets

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()

        // Configure calendar appearance for dark theme
        calendar.backgroundColor = .clear
        calendar.appearance.titleDefaultColor = .white
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.headerTitleColor = .white
        calendar.appearance.weekdayTextColor = .gray
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 17, weight: .semibold)
        calendar.appearance.weekdayFont = .systemFont(ofSize: 14, weight: .medium)
        calendar.appearance.titleFont = .systemFont(ofSize: 15, weight: .regular)
        
        // Selection styling
        calendar.appearance.selectionColor = UIColor.systemYellow
        calendar.appearance.todayColor = UIColor.systemYellow.withAlphaComponent(0.3)
        calendar.appearance.titleTodayColor = .white
        
        // Event styling
        calendar.appearance.eventDefaultColor = UIColor.systemYellow
        calendar.appearance.eventSelectionColor = UIColor.systemYellow
        
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator

        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // Only reload data if workoutData has changed
        if context.coordinator.workoutData != workoutData {
            uiView.reloadData()
            context.coordinator.workoutData = workoutData
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

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: FSCalendarView
        var workoutData: [Date: Int]

        init(_ parent: FSCalendarView) {
            self.parent = parent
            self.workoutData = parent.workoutData
        }

        // Return 0 here to remove the event dot under dates
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            return 0 // No event dot
        }

        // Handle date selection
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
            if monthPosition != .current {
                calendar.setCurrentPage(date, animated: true)
            }
        }

        // Minimum date to display
        func minimumDate(for calendar: FSCalendar) -> Date {
            return Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        }

        // Maximum date to display
        func maximumDate(for calendar: FSCalendar) -> Date {
            return Date()
        }

        // Customize the fill color for each date based on the number of sets
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
            // Get the number of sets for the date
            if let sets = workoutData.first(where: { Calendar.current.isDate($0.key, inSameDayAs: date) })?.value {
                if sets > 0 {
                    // Define the range for number of sets
                    let maxSets = 30.0 // Adjust based on your maximum expected sets
                    let minSets = 1.0

                    // Normalize the sets to a value between 0 and 1
                    let normalizedSets = CGFloat((Double(sets) - minSets) / (maxSets - minSets))
                    let clampedNormalizedSets = max(0.0, min(1.0, normalizedSets))

                    // Set the transparency based on the normalized set count (more sets = less transparent)
                    let alphaValue = clampedNormalizedSets * 0.7 + 0.1 // Ensures a minimum opacity
                    let greenColor = UIColor.systemGreen.withAlphaComponent(alphaValue)

                    return greenColor
                } else {
                    // No sets performed, return nil to indicate no color should be filled
                    return nil
                }
            } else if Calendar.current.isDateInToday(date) {
                // Ensure the current day is not highlighted if it has 0 sets
                return nil
            } else {
                // No data for this date, so return nil (no fill color)
                return nil
            }
        }

        // Customize the title color
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            return UIColor.white
        }
    }
}
