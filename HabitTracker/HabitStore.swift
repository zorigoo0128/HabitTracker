//
//  HabitStore.swift
//  HabitTracker
//
//  Created by Batzorig Byambabaatar on 2026.07.26.
//

import Foundation
import SwiftUI
import Combine
import WidgetKit

class HabitStore: ObservableObject {
    @Published var logs: [HabitLog] = [] {
        didSet {
            saveLogs()
        }
    }
    
    @Published var selectedCategoryFilter: HabitCategory? = nil
    @Published var selectedHeatmapDate: Date? = nil
    @Published var recentAddedToastMessage: String? = nil
    
    private let storageKey = "HabitTracker_Logs_V1"
    private let appGroupIdentifier = "group.com.zorigoo.HabitTracker"
    private let widgetKind = "HabitWidget"
    private var toastTimer: AnyCancellable?

    private var sharedDefaults: UserDefaults {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
            assertionFailure("Unable to access the HabitTracker App Group.")
            return .standard
        }
        return defaults
    }
    
    init() {
        if !loadLogs() {
            seedSampleData()
        }
    }
    
    // MARK: - Core Logging Methods
    
    func addLog(title: String, category: HabitCategory? = nil) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let targetCategory = category ?? inferCategory(from: trimmedTitle)
        let newLog = HabitLog(
            title: trimmedTitle,
            date: Date(),
            category: targetCategory,
            score: 1
        )
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            logs.insert(newLog, at: 0)
        }
        
        showToast(message: "Logged: \(trimmedTitle)")
    }
    
    func deleteLog(id: UUID) {
        withAnimation(.easeOut(duration: 0.2)) {
            logs.removeAll { $0.id == id }
        }
    }

    func clearAllHistory() {
        withAnimation(.easeOut(duration: 0.2)) {
            logs.removeAll()
            selectedCategoryFilter = nil
            selectedHeatmapDate = nil
        }
        showToast(message: "All history cleared")
    }
    
    func showToast(message: String) {
        toastTimer?.cancel()
        withAnimation(.spring()) {
            recentAddedToastMessage = message
        }
        toastTimer = Just(())
            .delay(for: .seconds(2.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                withAnimation(.easeOut) {
                    self?.recentAddedToastMessage = nil
                }
            }
    }
    
    // MARK: - Category Inference
    
    func inferCategory(from text: String) -> HabitCategory {
        let lower = text.lowercased()
        if lower.contains("homework") || lower.contains("duolingo") || lower.contains("read") || lower.contains("study") || lower.contains("book") || lower.contains("learn") {
            return .learning
        } else if lower.contains("workout") || lower.contains("gym") || lower.contains("run") || lower.contains("walk") || lower.contains("steps") || lower.contains("exercise") {
            return .fitness
        } else if lower.contains("water") || lower.contains("sleep") || lower.contains("eat") || lower.contains("health") || lower.contains("diet") || lower.contains("vitamin") {
            return .health
        } else if lower.contains("meditat") || lower.contains("journal") || lower.contains("mind") || lower.contains("breathe") || lower.contains("pray") {
            return .mindset
        } else if lower.contains("code") || lower.contains("task") || lower.contains("work") || lower.contains("project") || lower.contains("clean") || lower.contains("focus") {
            return .productivity
        }
        return .general
    }
    
    // MARK: - Filtering & Today Views
    
    var filteredTodayLogs: [HabitLog] {
        let today = Date()
        let calendar = Calendar.current
        return logs.filter { log in
            calendar.isDate(log.date, inSameDayAs: today) &&
            (selectedCategoryFilter == nil || log.category == selectedCategoryFilter)
        }
    }
    
    var logsForSelectedHeatmapDate: [HabitLog] {
        guard let date = selectedHeatmapDate else { return [] }
        let calendar = Calendar.current
        return logs.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    // MARK: - Stats & Heatmap Computation
    
    var totalLogsCount: Int {
        logs.count
    }
    
    var activeDaysCount: Int {
        Set(logs.map { $0.dateKey }).count
    }
    
    var currentStreak: Int {
        let calendar = Calendar.current
        let logDates = Set(logs.map { calendar.startOfDay(for: $0.date) })
        
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // If today has no logs yet, check starting from yesterday
        if !logDates.contains(checkDate) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }
        
        while logDates.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }
        
        return streak
    }
    
    var longestStreak: Int {
        let calendar = Calendar.current
        let sortedDates = Set(logs.map { calendar.startOfDay(for: $0.date) }).sorted()
        guard !sortedDates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var current = 1
        
        for i in 1..<sortedDates.count {
            let prev = sortedDates[i - 1]
            let curr = sortedDates[i]
            
            if let dayAfterPrev = calendar.date(byAdding: .day, value: 1, to: prev),
               calendar.isDate(dayAfterPrev, inSameDayAs: curr) {
                current += 1
                maxStreak = max(maxStreak, current)
            } else {
                current = 1
            }
        }
        
        return maxStreak
    }
    
    func dailyContributionMap() -> [String: Int] {
        var map: [String: Int] = [:]
        for log in logs {
            map[log.dateKey, default: 0] += 1
        }
        return map
    }
    
    func generateHeatmapColumns(numberOfWeeks: Int = 18) -> [[DailyContribution]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let map = dailyContributionMap()
        
        // Find current weekday (1: Sun, 2: Mon, ... 7: Sat)
        let weekday = calendar.component(.weekday, from: today)
        // Convert to 0: Mon ... 6: Sun
        let daysFromMonday = (weekday + 5) % 7
        
        // End date is Sunday of current week
        let daysToSunday = 6 - daysFromMonday
        guard let endDate = calendar.date(byAdding: .day, value: daysToSunday, to: today) else { return [] }
        
        let totalDays = numberOfWeeks * 7
        guard let startDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: endDate) else { return [] }
        
        var columns: [[DailyContribution]] = []
        var currentDate = startDate
        
        for _ in 0..<numberOfWeeks {
            var weekDays: [DailyContribution] = []
            for _ in 0..<7 {
                let dateKey = HabitLog.dateFormatter.string(from: currentDate)
                let count = map[dateKey] ?? 0
                
                let level: Int
                switch count {
                case 0: level = 0
                case 1: level = 1
                case 2: level = 2
                case 3, 4: level = 3
                default: level = 4
                }
                
                weekDays.append(DailyContribution(date: currentDate, dateKey: dateKey, count: count, level: level))
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            columns.append(weekDays)
        }
        
        return columns
    }
    
    // MARK: - Persistence
    
    private func saveLogs() {
        do {
            let data = try JSONEncoder().encode(logs)
            sharedDefaults.set(data, forKey: storageKey)
            WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
        } catch {
            print("Failed to save habit logs: \(error)")
        }
    }
    
    @discardableResult
    private func loadLogs() -> Bool {
        // Migrate logs written before the widget used the shared App Group.
        let data = sharedDefaults.data(forKey: storageKey) ?? UserDefaults.standard.data(forKey: storageKey)
        guard let data else { return false }
        do {
            logs = try JSONDecoder().decode([HabitLog].self, from: data)
            if sharedDefaults.data(forKey: storageKey) == nil {
                sharedDefaults.set(data, forKey: storageKey)
            }
            return true
        } catch {
            print("Failed to load habit logs: \(error)")
            return false
        }
    }
    
    // MARK: - Seed Data for First Launch
    
    private func seedSampleData() {
        let calendar = Calendar.current
        let today = Date()
        var sampleLogs: [HabitLog] = []
        
        let sampleActivities: [(title: String, category: HabitCategory)] = [
            ("Did Duolingo lesson", .learning),
            ("I did some homework", .learning),
            ("Read 20 pages of book", .learning),
            ("30-min morning workout", .fitness),
            ("Walked 8,500 steps", .fitness),
            ("Drank 2L water", .health),
            ("8 hours restful sleep", .health),
            ("Meditated for 10 min", .mindset),
            ("Wrote in gratitude journal", .mindset),
            ("Completed code refactoring", .productivity),
            ("Reviewed weekly goals", .productivity)
        ]
        
        // Generate random realistic activity logs over past 120 days
        for dayOffset in (0...120).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            // Random chance of activity (higher probability on recent days)
            let chance = Double.random(in: 0...1)
            let numActivities: Int
            if dayOffset < 30 {
                numActivities = chance > 0.15 ? Int.random(in: 1...4) : 0
            } else {
                numActivities = chance > 0.3 ? Int.random(in: 1...3) : 0
            }
            
            for _ in 0..<numActivities {
                let activity = sampleActivities.randomElement()!
                let randomMinutes = Int.random(in: 8...21)
                let randomHours = Int.random(in: 8...20)
                var components = calendar.dateComponents([.year, .month, .day], from: date)
                components.hour = randomHours
                components.minute = randomMinutes
                let logDate = calendar.date(from: components) ?? date
                
                sampleLogs.append(HabitLog(title: activity.title, date: logDate, category: activity.category))
            }
        }
        
        self.logs = sampleLogs.sorted(by: { $0.date > $1.date })
    }
}
