//
//  AIPromptInputBar.swift
//  HabitTracker
//
//  Created by Batzorig Byambabaatar on 2026.07.26.
//

import SwiftUI

struct AIPromptInputBar: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var textInput: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            // Sparkles AI Icon
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.emeraldAccent, .cyanAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(.degrees(isFocused ? 15 : 0))
                .animation(.easeInOut(duration: 0.3), value: isFocused)
            
            // Text Input
            TextField("Log today's activity...", text: $textInput)
                .font(.body)
                .focused($isFocused)
                .submitLabel(.send)
                .onSubmit {
                    submitLog()
                }
            
            // Send Button
            Button(action: submitLog) {
                ZStack {
                    Circle()
                        .fill(
                            textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? AnyShapeStyle(Color.white.opacity(0.1))
                            : AnyShapeStyle(LinearGradient(colors: [.emeraldAccent, .cyanAccent], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(
                            textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.white.opacity(0.3)
                            : Color.black
                        )
                }
            }
            .buttonStyle(.plain)
            .disabled(textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: isFocused
                                ? [Color.emeraldAccent.opacity(0.6), Color.cyanAccent.opacity(0.6)]
                                : [Color.white.opacity(0.25), Color.white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isFocused ? 1.5 : 1
                        )
                )
                .shadow(
                    color: isFocused ? Color.emeraldAccent.opacity(0.2) : Color.black.opacity(0.15),
                    radius: isFocused ? 16 : 10,
                    x: 0,
                    y: 4
                )
        )
    }
    
    private func submitLog() {
        let trimmed = textInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        habitStore.addLog(title: trimmed)
        textInput = ""
        isFocused = false
    }
}
