//
//  Untitled.swift
//  Reps
//
//  Created by Aditya Rai on 12/2/24.
//


import SwiftUI
import SwiftData

// MARK: - Graphs View
struct GraphsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var exerciseHistories: [ExerciseHistory] = []
    @State private var selectedExercise: String?
    @State private var exercises: Set<String> = []
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: MetricType = .weight
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    enum MetricType: String, CaseIterable {
        case weight = "Weight"
        case volume = "Volume"
        case reps = "Reps"
    }
    
    enum GroupingType {
        case daily
        case weekly
        case monthly
        case yearly
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .cornerRadius(2.5)
                .padding(.top, 8)
                .padding(.bottom, 4)
            
            Text("Graphs")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 16)
            
            VStack(spacing: 20) {
                exerciseSelector
                
                if let selectedExercise = selectedExercise {
                    metricSelector
                    timeRangeSelector
                    graphContent(for: selectedExercise)
                } else {
                    noExerciseSelectedView
                }
            }
            .padding(.vertical)
        }
        .background(Color.black)
        .navigationBarHidden(true)
        .onAppear {
            loadExerciseHistory()
        }
    }
    
    private var exerciseSelector: some View {
        Group {
            if !exercises.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(exercises), id: \.self) { exercise in
                            exerciseButton(for: exercise)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func exerciseButton(for exercise: String) -> some View {
        Button(action: {
            withAnimation {
                hapticFeedback.impactOccurred()
                selectedExercise = selectedExercise == exercise ? nil : exercise
            }
        }) {
            Text(exercise)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selectedExercise == exercise ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    selectedExercise == exercise ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2)
                )
                .cornerRadius(12)
        }
    }
    
    private var metricSelector: some View {
        HStack(spacing: 16) {
            ForEach(MetricType.allCases, id: \.self) { metric in
                metricButton(for: metric)
            }
        }
        .padding(.horizontal)
    }
    
    private func metricButton(for metric: MetricType) -> some View {
        Button(action: {
            withAnimation {
                hapticFeedback.impactOccurred()
                selectedMetric = metric
            }
        }) {
            Text(metric.rawValue)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(selectedMetric == metric ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    selectedMetric == metric ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2)
                )
                .cornerRadius(12)
        }
    }
    
    private var timeRangeSelector: some View {
        HStack(spacing: 16) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                timeRangeButton(for: range)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func timeRangeButton(for range: TimeRange) -> some View {
        Button(action: {
            withAnimation {
                hapticFeedback.impactOccurred()
                selectedTimeRange = range
            }
        }) {
            Text(range.rawValue)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(selectedTimeRange == range ? .white : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    selectedTimeRange == range ? Color.gray.opacity(0.3) : Color.clear
                )
                .cornerRadius(8)
        }
    }
    
    private func graphContent(for exercise: String) -> some View {
        let points = getGraphPoints(for: exercise)
        return Group {
            if points.isEmpty {
                Text("No data available for the selected timeframe")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                ScrollView {
                    graphForSelectedMetric(points: points)
                }
            }
        }
    }
    
    private func graphForSelectedMetric(points: MetricPoints) -> some View {
        Group {
            switch selectedMetric {
            case .weight:
                graphView(title: "Weight", points: points.weight)
            case .volume:
                graphView(title: "Volume (weight × reps)", points: points.volume)
            case .reps:
                graphView(title: "Average Reps", points: points.reps)
            }
        }
    }
    
    private func graphView(title: String, points: [GraphPoint]) -> some View {
        ExerciseGraph(
            title: title,
            points: points,
            color: .green,
            timeRange: selectedTimeRange
        )
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
        .frame(height: 300)
        .padding(.bottom, 40)
    }
    
    private var noExerciseSelectedView: some View {
        VStack(spacing: 16) {
            Text("Select an exercise")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
        .background(.black)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func getGroupingType(_ timeRange: TimeRange) -> GroupingType {
        switch timeRange {
        case .week:
            return .daily
        case .month, .threeMonths:
            return .weekly
        case .sixMonths, .year:
            return .monthly
        case .all:
            return .yearly
        }
    }
    
    private func getDaysToShow(_ timeRange: TimeRange) -> Int {
        switch timeRange {
        case .week:
            return 7
        case .month:
            return 28
        case .threeMonths:
            return 84
        case .sixMonths:
            return 180
        case .year:
            return 365
        case .all:
            return 3650
        }
    }
    
    private func getGraphPoints(for exercise: String) -> MetricPoints {
        let calendar = Calendar.current
        let now = Date()
        let days = getDaysToShow(selectedTimeRange)
        let startDate = calendar.date(byAdding: .day, value: -days, to: now) ?? now
        
        let filteredHistories = exerciseHistories.filter { history in
            history.exerciseName == exercise && history.timestamp >= startDate
        }
        
        var points = MetricPoints()
        let grouping = getGroupingType(selectedTimeRange)
        
        switch grouping {
        case .daily:
            points = calculateDailyMetrics(histories: filteredHistories)
        case .weekly:
            points = calculateWeeklyMetrics(histories: filteredHistories)
        case .monthly:
            points = calculateMonthlyMetrics(histories: filteredHistories)
        case .yearly:
            points = calculateYearlyMetrics(histories: filteredHistories)
        }
        
        return points
    }
    
    private struct MetricPoints {
        var weight: [GraphPoint] = []
        var reps: [GraphPoint] = []
        var volume: [GraphPoint] = []
        var isEmpty: Bool {
            weight.isEmpty && reps.isEmpty && volume.isEmpty
        }
    }
    
    private func loadExerciseHistory() {
        do {
            let descriptor = FetchDescriptor<ExerciseHistory>(
                sortBy: [SortDescriptor(\.timestamp, order: .forward)]
            )
            exerciseHistories = try modelContext.fetch(descriptor)
            exercises = Set(exerciseHistories.map { $0.exerciseName })
        } catch {
            print("Failed to load exercise history: \(error)")
        }
    }
    
    private func calculateWeeklyMetrics(histories: [ExerciseHistory]) -> MetricPoints {
        let calendar = Calendar.current
        let groupedHistories = Dictionary(grouping: histories) { history in
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: history.timestamp)
            return calendar.date(from: components) ?? history.timestamp
        }
        
        return calculateAveragedMetrics(groupedHistories: groupedHistories, periodLabel: "week")
    }
    
    private func calculateMonthlyMetrics(histories: [ExerciseHistory]) -> MetricPoints {
        let calendar = Calendar.current
        let groupedHistories = Dictionary(grouping: histories) { history in
            let components = calendar.dateComponents([.year, .month], from: history.timestamp)
            return calendar.date(from: components) ?? history.timestamp
        }
        
        return calculateAveragedMetrics(groupedHistories: groupedHistories, periodLabel: "month")
    }
    
    private func calculateYearlyMetrics(histories: [ExerciseHistory]) -> MetricPoints {
        let calendar = Calendar.current
        let groupedHistories = Dictionary(grouping: histories) { history in
            let components = calendar.dateComponents([.year], from: history.timestamp)
            return calendar.date(from: components) ?? history.timestamp
        }
        
        return calculateAveragedMetrics(groupedHistories: groupedHistories, periodLabel: "year")
    }
    
    private func calculateAveragedMetrics(groupedHistories: [Date: [ExerciseHistory]], periodLabel: String) -> MetricPoints {
        let sortedDates = groupedHistories.keys.sorted()
        var points = MetricPoints()
        
        for date in sortedDates {
            let periodHistories = groupedHistories[date] ?? []
            
            // Maximum weight for the period
            if let maxWeight = periodHistories.map({ $0.weight }).max() {
                points.weight.append(GraphPoint(
                    date: date,
                    value: Double(maxWeight),
                    label: "\(Formatter.decimal(maxWeight)) lbs"
                ))
            }
            
            // Average reps for the period
            let avgReps = periodHistories.map { $0.reps }.reduce(0.0, +) / Double(periodHistories.count)
            points.reps.append(GraphPoint(
                date: date,
                value: avgReps,
                label: "\(Formatter.decimal(avgReps)) reps avg"
            ))
            
            // Average volume for the period
            let avgVolume = periodHistories.reduce(0.0) { $0 + ($1.weight * $1.reps) } / Double(periodHistories.count)
            points.volume.append(GraphPoint(
                date: date,
                value: avgVolume,
                label: "\(Formatter.decimal(avgVolume)) lbs avg"
            ))
        }
        
        return points
    }
    
    private func calculateDailyMetrics(histories: [ExerciseHistory]) -> MetricPoints {
        let calendar = Calendar.current
        let groupedHistories = Dictionary(grouping: histories) { history in
            calendar.startOfDay(for: history.timestamp)
        }
        
        let sortedDates = groupedHistories.keys.sorted()
        var points = MetricPoints()
        
        for date in sortedDates {
            let dayHistories = groupedHistories[date] ?? []
            
            // Maximum weight for the day
            if let maxWeight = dayHistories.map({ $0.weight }).max() {
                points.weight.append(GraphPoint(
                    date: date,
                    value: Double(maxWeight),
                    label: "\(Formatter.decimal(maxWeight)) lbs"
                ))
            }
            
            // Average reps for the day
            let avgReps = dayHistories.map { $0.reps }.reduce(0.0, +) / Double(dayHistories.count)
            points.reps.append(GraphPoint(
                date: date,
                value: avgReps,
                label: "\(Formatter.decimal(avgReps)) reps avg"
            ))
            
            // Total volume for the day
            let totalVolume = dayHistories.reduce(0.0) { $0 + ($1.weight * $1.reps) }
            points.volume.append(GraphPoint(
                date: date,
                value: totalVolume,
                label: "\(Formatter.decimal(totalVolume)) lbs"
            ))
        }
        
        return points
    }
}
