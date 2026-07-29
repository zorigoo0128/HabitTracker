//
//  HabitWidget.swift
//  HabitWidget
//
//  Created by Batzorig Byambabaatar on 2026.07.26.
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry & Data Provider

struct WidgetHabitEntry: TimelineEntry {
    let date: Date
    let contributionMap: [String: Int] // "yyyy-MM-dd" -> log count
    let streak: Int
    let totalLogs: Int
}

struct Provider: TimelineProvider {
    typealias Entry = WidgetHabitEntry
    private let storageKey = "HabitTracker_Logs_V1"
    private let appGroupIdentifier = "group.com.zorigoo.HabitTracker"
    
    func placeholder(in context: Context) -> WidgetHabitEntry {
        WidgetHabitEntry(date: Date(), contributionMap: sampleMap(), streak: 5, totalLogs: 42)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetHabitEntry) -> Void) {
        let (map, streak, total) = loadHabitData()
        let entry = WidgetHabitEntry(date: Date(), contributionMap: map, streak: streak, totalLogs: total)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetHabitEntry>) -> Void) {
        let (map, streak, total) = loadHabitData()
        let currentDate = Date()
        let entry = WidgetHabitEntry(date: currentDate, contributionMap: map, streak: streak, totalLogs: total)
        
        // The app reloads this timeline whenever a log changes. This refresh also
        // ensures the heatmap advances at the next day boundary if the app stays closed.
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadHabitData() -> ([String: Int], Int, Int) {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = defaults.data(forKey: storageKey) else {
            return ([:], 0, 0)
        }
        
        struct SimpleLog: Codable {
            let date: Date
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        
        do {
            let logs = try JSONDecoder().decode([SimpleLog].self, from: data)
            var map: [String: Int] = [:]
            var logDates: Set<Date> = []
            
            for log in logs {
                let key = formatter.string(from: log.date)
                map[key, default: 0] += 1
                logDates.insert(calendar.startOfDay(for: log.date))
            }
            
            // Calculate current streak
            var streak = 0
            var checkDate = calendar.startOfDay(for: Date())
            if !logDates.contains(checkDate) {
                if let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) {
                    checkDate = yesterday
                }
            }
            while logDates.contains(checkDate) {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = prev
            }
            
            return (map, streak, logs.count)
        } catch {
            return ([:], 0, 0)
        }
    }
    
    private func sampleMap() -> [String: Int] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let today = Date()
        var map: [String: Int] = [:]
        
        for offset in 0..<120 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                let key = formatter.string(from: date)
                let count = (offset % 3 == 0 || offset % 5 == 0) ? (offset % 4 + 1) : 0
                map[key] = count
            }
        }
        return map
    }
}

// MARK: - Widget Heatmap View

struct WidgetHeatmapView: View {
    let entry: WidgetHabitEntry
    @Environment(\.widgetFamily) var family
    
    private var minimumNumberOfWeeks: Int {
        switch family {
        case .systemSmall: return 6
        case .systemMedium: return 15
        default: return 18
        }
    }
    
    private var preferredTileSize: CGFloat {
        switch family {
        case .systemSmall: return 10
        case .systemMedium: return 11
        default: return 13
        }
    }
    
    private var tileSpacing: CGFloat { 3.5 }
    
    var body: some View {
        VStack(alignment: .leading, spacing: family == .systemSmall ? 6 : 8) {
            // Widget Title & Header
            HStack(alignment: .center) {
                HStack(spacing: 5) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: family == .systemSmall ? 12 : 14, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [Color(red: 0.2, green: 0.88, blue: 0.58), Color(red: 0.15, green: 0.78, blue: 0.98)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    Text("90 DAY CHALLENGE")
                        .font(.system(size: family == .systemSmall ? 12 : 14, weight: .bold))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                if family != .systemSmall {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 1.0, green: 0.55, blue: 0.2))
                        Text("\(entry.streak)d")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Heatmap Grid Matrix
            GeometryReader { proxy in
                let layout = gridLayout(in: proxy.size)
                let columns = generateColumns(weeks: layout.weeks)

                HStack(spacing: tileSpacing) {
                    ForEach(0..<columns.count, id: \.self) { weekIdx in
                        VStack(spacing: tileSpacing) {
                            ForEach(0..<7, id: \.self) { dayIdx in
                                let level = columns[weekIdx][dayIdx]
                                RoundedRectangle(cornerRadius: min(2.5, layout.tileSize / 3), style: .continuous)
                                    .fill(colorForLevel(level))
                                    .frame(width: layout.tileSize, height: layout.tileSize)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: min(2.5, layout.tileSize / 3), style: .continuous)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .padding(12)
    }

    private func gridLayout(in size: CGSize) -> (weeks: Int, tileSize: CGFloat) {
        let maximumTileSize = min(
            preferredTileSize,
            max(4, (size.height - tileSpacing * 6) / 7)
        )
        let weeksNeededToFillWidth = Int(ceil((size.width + tileSpacing) / (maximumTileSize + tileSpacing)))
        let weeks = max(minimumNumberOfWeeks, weeksNeededToFillWidth)
        let resolvedTileSize = max(3, (size.width - tileSpacing * CGFloat(weeks - 1)) / CGFloat(weeks))

        return (weeks, resolvedTileSize)
    }
    
    private func generateColumns(weeks: Int) -> [[Int]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: entry.date)
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let daysToSunday = 6 - daysFromMonday
        
        guard let endDate = calendar.date(byAdding: .day, value: daysToSunday, to: today) else { return [] }
        let totalDays = weeks * 7
        guard let startDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: endDate) else { return [] }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var cols: [[Int]] = []
        var curr = startDate
        
        for _ in 0..<weeks {
            var weekLevels: [Int] = []
            for _ in 0..<7 {
                let key = formatter.string(from: curr)
                let count = entry.contributionMap[key] ?? 0
                let level: Int
                switch count {
                case 0: level = 0
                case 1: level = 1
                case 2: level = 2
                case 3, 4: level = 3
                default: level = 4
                }
                weekLevels.append(level)
                curr = calendar.date(byAdding: .day, value: 1, to: curr) ?? curr
            }
            cols.append(weekLevels)
        }
        return cols
    }
    
    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0: return Color.white.opacity(0.06)
        case 1: return Color(red: 0.1, green: 0.45, blue: 0.32).opacity(0.6)
        case 2: return Color(red: 0.15, green: 0.65, blue: 0.42).opacity(0.85)
        case 3: return Color(red: 0.2, green: 0.82, blue: 0.52)
        case 4: return Color(red: 0.25, green: 0.98, blue: 0.62)
        default: return Color.white.opacity(0.06)
        }
    }
}

// MARK: - Habit Widget Declaration

struct HabitWidget: Widget {
    let kind: String = "HabitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetHeatmapView(entry: entry)
                .containerBackground(Color(red: 0.07, green: 0.08, blue: 0.12), for: .widget)
        }
        .configurationDisplayName("Habit Heatmap")
        .description("Displays your contribution heatmap and streak.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

