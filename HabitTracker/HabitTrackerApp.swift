//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Batzorig Byambabaatar on 2026.07.26.
//
import SwiftUI

// MARK: - App Delegate for Quitting on Window Close
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct HabitTrackerApp: App {
    @StateObject private var habitStore = HabitStore()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    
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
