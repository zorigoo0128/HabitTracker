//
//  QuickRecommendView.swift
//  HabitTracker
//
//  Created by Batzorig Byambabaatar on 2026.07.26.
//

import SwiftUI

struct QuickRecommendView: View {
    @EnvironmentObject var habitStore: HabitStore
    let presets: [HabitPreset] = HabitPreset.defaultPresets
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.caption2)
                    .foregroundStyle(.cyanAccent)
                Text("Quick Log Recommends")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
            .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(presets) { preset in
                        RecommendationChip(preset: preset) {
                            habitStore.addLog(title: preset.title, category: preset.category)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

struct RecommendationChip: View {
    let preset: HabitPreset
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                onTap()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: preset.icon)
                    .font(.caption)
                    .foregroundStyle(preset.category.color)
                
                Text(preset.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Image(systemName: "plus")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .glassPill(isSelected: isPressed)
            .scaleEffect(isPressed ? 0.94 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
