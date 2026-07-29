//
//  AppSettingsView.swift
//  HabitTracker
//

import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @State private var showingClearHistoryConfirmation = false

    var body: some View {
        Form {
            Section {
                LabeledContent("Recorded logs") {
                    Text("\(habitStore.totalLogsCount)")
                        .foregroundStyle(.secondary)
                }

                LabeledContent("Active days") {
                    Text("\(habitStore.activeDaysCount)")
                        .foregroundStyle(.secondary)
                }

                Divider()

                Button(role: .destructive) {
                    showingClearHistoryConfirmation = true
                } label: {
                    Label("Clear All History", systemImage: "trash")
                }
                .disabled(habitStore.logs.isEmpty)
            } header: {
                Text("History")
            } footer: {
                Text("This permanently removes every habit log from the app and its widget.")
            }

            Section {
                LabeledContent("App") {
                    Text("Habit Tracker")
                }
                LabeledContent("Version") {
                    Text("1.0")
                }
            } header: {
                Text("About")
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 420)
        .alert("Clear all history?", isPresented: $showingClearHistoryConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All History", role: .destructive) {
                habitStore.clearAllHistory()
            }
        } message: {
            Text("This permanently removes all logged habits and clears the widget heatmap. This action cannot be undone.")
        }
    }
}
