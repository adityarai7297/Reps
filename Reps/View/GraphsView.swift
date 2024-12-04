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
    @State private var selectedTimeframe: TimeFrame = .week
    @State private var selectedExercise: String?
    @State private var exercises: Set<String> = []
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time frame selector
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Exercise selector
                if !exercises.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(exercises), id: \.self) { exercise in
                                Button(action: {
                                    withAnimation {
                                        selectedExercise = selectedExercise == exercise ? nil : exercise
                                    }
                                }) {
                                    Text(exercise)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedExercise == exercise ? .black : .white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedExercise == exercise ? Color.green : Color.black.opacity(0.3)
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                if let selectedExercise = selectedExercise {
                    // Graphs
                    VStack(spacing: 24) {
                        let points = getGraphPoints(for: selectedExercise)
                        
                        if points.isEmpty {
                            Text("No data available for the selected timeframe")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            // Weight Graph
                            ExerciseGraph(
                                title: "Weight",
                                points: points.weight,
                                color: .green
                            )
                            .padding(.horizontal)
                            
                            // Reps Graph
                            ExerciseGraph(
                                title: "Repetitions",
                                points: points.reps,
                                color: .green
                            )
                            .padding(.horizontal)
                            
                            // Sets Graph
                            ExerciseGraph(
                                title: "Sets",
                                points: points.sets,
                                color: .green
                            )
                            .padding(.horizontal)
                            
                            // Volume Graph
                            ExerciseGraph(
                                title: "Volume (weight × reps)",
                                points: points.volume,
                                color: .green
                            )
                            .padding(.horizontal)
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Select an exercise to view detailed metrics")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 60)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            loadExerciseHistory()
        }
        .onChange(of: selectedTimeframe) { _ in
            loadExerciseHistory()
        }
    }
    
    private struct MetricPoints {
        var weight: [GraphPoint] = []
        var reps: [GraphPoint] = []
        var sets: [GraphPoint] = []
        var volume: [GraphPoint] = []
        var isEmpty: Bool {
            weight.isEmpty && reps.isEmpty && sets.isEmpty && volume.isEmpty
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
    
    private func getGraphPoints(for exercise: String) -> MetricPoints {
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        switch selectedTimeframe {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        }
        
        let filteredHistories = exerciseHistories.filter { history in
            history.exerciseName == exercise && history.timestamp >= startDate
        }
        
        let groupedHistories = Dictionary(grouping: filteredHistories) { history in
            calendar.startOfDay(for: history.timestamp)
        }
        
        let sortedDates = groupedHistories.keys.sorted()
        var points = MetricPoints()
        
        for date in sortedDates {
            let histories = groupedHistories[date] ?? []
            
            // Weight - use the maximum weight for the day
            if let maxWeight = histories.map({ $0.weight }).max() {
                points.weight.append(GraphPoint(
                    date: date,
                    value: Double(maxWeight),
                    label: "\(Formatter.decimal(maxWeight)) lbs"
                ))
            }
            
            // Total reps for the day
            let totalReps = histories.reduce(0) { $0 + $1.reps }
            points.reps.append(GraphPoint(
                date: date,
                value: Double(totalReps),
                label: "\(Formatter.decimal(totalReps)) reps"
            ))
            
            // Sets count for the day
            points.sets.append(GraphPoint(
                date: date,
                value: Double(histories.count),
                label: "\(histories.count) sets"
            ))
            
            // Total volume (weight × reps) for the day
            let totalVolume = histories.reduce(0) { $0 + ($1.weight * $1.reps) }
            points.volume.append(GraphPoint(
                date: date,
                value: Double(totalVolume),
                label: "\(Formatter.decimal(totalVolume)) lbs"
            ))
        }
        
        return points
    }
}
