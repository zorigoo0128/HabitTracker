//
//  ContributionHeatmapView.swift
//  HabitTracker
//
//  Created by Batzorig Byambabaatar on 2026.07.26.
//

import SwiftUI

struct ContributionHeatmapView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var showingDayDetails = false
    
    private let weekDays = ["M", "", "W", "", "F", "", "S"]
    private let tileSize: CGFloat = 14
    private let tileSpacing: CGFloat = 4
    private let weekdayLabelWidth: CGFloat = 24

    private struct MonthLabel: Identifiable {
        let weekIndex: Int
        let title: String

        var id: Int { weekIndex }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header Stats & Title
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.grid.3x3.topleft.filled")
                            .foregroundStyle(LinearGradient(colors: [.emeraldAccent, .cyanAccent], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .font(.title3)
                        Text("Contribution Heatmap")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                    Text("\(habitStore.activeDaysCount) active days logged")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Streak Pill Badge
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orangeAccent)
                    Text("\(habitStore.currentStreak) day streak")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .glassPill(isSelected: habitStore.currentStreak > 0)
            }
            
            // Heatmap Matrix
            GeometryReader { proxy in
                let layout = heatmapLayout(for: proxy.size.width)
                let columns = habitStore.generateHeatmapColumns(numberOfWeeks: layout.weeks)
                let labels = monthLabels(in: columns, availableWidth: proxy.size.width)

                VStack(alignment: .leading, spacing: 6) {
                    // Month Headers
                    HStack(spacing: tileSpacing) {
                        Text(String(Calendar.current.component(.year, from: Date())))
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(.tertiary)
                            .frame(width: weekdayLabelWidth, alignment: .leading)

                        ZStack(alignment: .leading) {
                            ForEach(labels) { label in
                                Text(label.title)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .offset(x: CGFloat(label.weekIndex) * (layout.tileSize + layout.columnSpacing))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack(alignment: .top, spacing: tileSpacing) {
                        // Weekday labels
                        VStack(spacing: tileSpacing) {
                            ForEach(0..<7, id: \.self) { dayIndex in
                                Text(weekDays[dayIndex])
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.tertiary)
                                    .frame(width: weekdayLabelWidth, height: layout.tileSize, alignment: .center)
                            }
                        }
                        
                        // Grid Columns
                        HStack(spacing: layout.columnSpacing) {
                            ForEach(0..<columns.count, id: \.self) { weekIndex in
                                VStack(spacing: tileSpacing) {
                                    ForEach(columns[weekIndex]) { contribution in
                                        HeatmapSquareTile(
                                            contribution: contribution,
                                            isSelected: isSelectedDate(contribution.date),
                                            tileSize: layout.tileSize
                                        ) {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                if habitStore.selectedHeatmapDate != nil && Calendar.current.isDate(habitStore.selectedHeatmapDate!, inSameDayAs: contribution.date) {
                                                    habitStore.selectedHeatmapDate = nil
                                                } else {
                                                    habitStore.selectedHeatmapDate = contribution.date
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(height: 146)
            
            // Heatmap Legend & Selected Date Info
            HStack {
                if let selectedDate = habitStore.selectedHeatmapDate {
                    let formattedDate = formatDate(selectedDate)
                    let count = habitStore.logsForSelectedHeatmapDate.count
                    HStack(spacing: 6) {
                        Text(formattedDate)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.emeraldAccent)
                        Text("• \(count) log\(count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            habitStore.selectedHeatmapDate = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                } else {
                    Text("Tap any square to inspect logs")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                // Heatmap Legend
                HStack(spacing: 4) {
                    Text("Less")
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                    
                    ForEach(0..<5, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color.heatmapColor(for: level))
                            .frame(width: 10, height: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            )
                    }
                    
                    Text("More")
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
            }
            
            // Popover Details if a heatmap day is selected
            if let _ = habitStore.selectedHeatmapDate {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    if habitStore.logsForSelectedHeatmapDate.isEmpty {
                        Text("No logs recorded for this day.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .italic()
                            .padding(.vertical, 4)
                    } else {
                        ForEach(habitStore.logsForSelectedHeatmapDate) { log in
                            HStack(spacing: 8) {
                                Image(systemName: log.category.icon)
                                    .font(.caption)
                                    .foregroundStyle(log.category.color)
                                    .frame(width: 20, height: 20)
                                    .background(log.category.color.opacity(0.15))
                                    .clipShape(Circle())
                                
                                Text(log.title)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Text(log.formattedTime)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 24)
    }
    
    private func isSelectedDate(_ date: Date) -> Bool {
        guard let selected = habitStore.selectedHeatmapDate else { return false }
        return Calendar.current.isDate(selected, inSameDayAs: date)
    }

    private func heatmapLayout(for availableWidth: CGFloat) -> (weeks: Int, tileSize: CGFloat, columnSpacing: CGFloat) {
        let gridWidth = max(availableWidth - weekdayLabelWidth - tileSpacing, 0)
        let idealColumnWidth = tileSize + tileSpacing
        let weeks = max(18, Int((gridWidth + tileSpacing) / idealColumnWidth))
        let compactTileSize = min(tileSize, (gridWidth - tileSpacing * CGFloat(weeks - 1)) / CGFloat(weeks))
        let resolvedTileSize = max(8, compactTileSize)
        let columnSpacing = weeks > 1
            ? max(tileSpacing, (gridWidth - resolvedTileSize * CGFloat(weeks)) / CGFloat(weeks - 1))
            : 0

        return (weeks, resolvedTileSize, columnSpacing)
    }

    private func monthLabels(in columns: [[DailyContribution]], availableWidth: CGFloat) -> [MonthLabel] {
        let calendar = Calendar.current
        let candidates = columns.enumerated().compactMap { index, week -> MonthLabel? in
            guard let firstDayOfMonth = week.first(where: { calendar.component(.day, from: $0.date) == 1 }) else {
                return nil
            }
            return MonthLabel(weekIndex: index, title: monthAbbreviation(for: firstDayOfMonth.date))
        }

        let maximumLabels = min(4, max(2, Int(availableWidth / 180)))
        guard candidates.count > maximumLabels else { return candidates }

        let step = Double(candidates.count - 1) / Double(maximumLabels - 1)
        return (0..<maximumLabels).map { index in
            candidates[Int((Double(index) * step).rounded())]
        }
    }
    
    private func monthAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct HeatmapSquareTile: View {
    let contribution: DailyContribution
    let isSelected: Bool
    let tileSize: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                .fill(Color.heatmapColor(for: contribution.level))
                .frame(width: tileSize, height: tileSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                        .stroke(
                            isSelected ? Color.cyanAccent : Color.white.opacity(0.12),
                            lineWidth: isSelected ? 1.5 : 0.5
                        )
                )
                .shadow(color: isSelected ? Color.cyanAccent.opacity(0.5) : Color.clear, radius: 4)
                .scaleEffect(isSelected ? 1.25 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
