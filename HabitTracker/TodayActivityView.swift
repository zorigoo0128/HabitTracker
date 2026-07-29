//
//  TodayActivityView.swift
//  HabitTracker
//
//  Created by Batzorig Byambabaatar on 2026.07.26.
//

import SwiftUI

struct TodayActivityView: View {
    @EnvironmentObject var habitStore: HabitStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header & Filter Bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.day.timeline.left")
                        .foregroundStyle(Color.cyanAccent)
                        .font(.title3)
                    Text("Today's Activity")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Text("\(habitStore.filteredTodayLogs.count) completed")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            // Category Filter Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All",
                        icon: "square.grid.2x2",
                        color: .primary,
                        isSelected: habitStore.selectedCategoryFilter == nil
                    ) {
                        withAnimation { habitStore.selectedCategoryFilter = nil }
                    }
                    
                    ForEach(HabitCategory.allCases) { category in
                        FilterChip(
                            title: category.rawValue,
                            icon: category.icon,
                            color: category.color,
                            isSelected: habitStore.selectedCategoryFilter == category
                        ) {
                            withAnimation { habitStore.selectedCategoryFilter = category }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            
            // Logs List
            if habitStore.filteredTodayLogs.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "checklist.checked")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("No logs recorded for today yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Use the prompt input or tap a recommend chip below to register an activity!")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 8) {
                    ForEach(habitStore.filteredTodayLogs) { log in
                        LogItemRow(log: log) {
                            habitStore.deleteLog(id: log.id)
                        }
                    }
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 24)
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white : color)
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .glassPill(isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }
}

struct LogItemRow: View {
    let log: HabitLog
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon Badge
            ZStack {
                Circle()
                    .fill(log.category.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: log.category.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(log.category.color)
            }
            
            // Title & Category Name
            VStack(alignment: .leading, spacing: 2) {
                Text(log.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 6) {
                    Text(log.category.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(log.category.color)
                    
                    Text("• \(log.formattedTime)")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                )
        )
    }
}
