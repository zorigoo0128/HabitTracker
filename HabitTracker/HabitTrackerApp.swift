//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Batzorig Byambabaatar on 2026.07.26.
//

import SwiftUI

@main
struct HabitTrackerApp: App {
    @StateObject private var habitStore = HabitStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(habitStore)
        }

        Settings {
            AppSettingsView()
                .environmentObject(habitStore)
        }
    }
}
