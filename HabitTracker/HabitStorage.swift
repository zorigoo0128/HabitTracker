//
//  HabitStorage.swift
//  HabitTracker
//
//  Created by Antigravity on 2026.09.14.
//

import Foundation
import WidgetKit

@MainActor
enum HabitStorage {
    static let storageKey = "HabitTracker_Logs_V1"
    static let appGroupIdentifier = "group.com.zorigoo.HabitTracker"
    static let widgetKind = "HabitWidget"
    static let didUpdateLogsNotification = Notification.Name("com.zorigoo.HabitTracker.didUpdateLogs")
    
    static var sharedDefaults: UserDefaults {
        if let defaults = UserDefaults(suiteName: appGroupIdentifier) {
            return defaults
        }
        assertionFailure("Unable to access the HabitTracker App Group.")
        return .standard
    }
    
    // MARK: - Load & Save
    
    static func loadLogs() -> [HabitLog] {
        let defaults = sharedDefaults
        let data = defaults.data(forKey: storageKey) ?? UserDefaults.standard.data(forKey: storageKey)
        guard let data else { return [] }
        
        do {
            let logs = try JSONDecoder().decode([HabitLog].self, from: data)
            if defaults.data(forKey: storageKey) == nil {
                defaults.set(data, forKey: storageKey)
            }
            return logs
        } catch {
            print("Failed to decode habit logs: \(error)")
            return []
        }
    }
    
    static func saveLogs(_ logs: [HabitLog], broadcast: Bool = true) {
        do {
            let data = try JSONEncoder().encode(logs)
            sharedDefaults.set(data, forKey: storageKey)
            WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
            
            if broadcast {
                broadcastUpdate()
            }
        } catch {
            print("Failed to encode habit logs: \(error)")
        }
    }
    
    // MARK: - Append Log
    
    @discardableResult
    static func appendLog(title: String, category: HabitCategory? = nil, note: String? = nil, date: Date = Date(), score: Int = 1) -> HabitLog {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let targetCategory = category ?? HabitCategory.infer(from: trimmedTitle)
        
        let newLog = HabitLog(
            title: trimmedTitle,
            date: date,
            category: targetCategory,
            note: note,
            score: score
        )
        
        var currentLogs = loadLogs()
        currentLogs.insert(newLog, at: 0)
        
        do {
            let data = try JSONEncoder().encode(currentLogs)
            sharedDefaults.set(data, forKey: storageKey)
            WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
            broadcastUpdate(title: trimmedTitle)
        } catch {
            print("Failed to save habit log: \(error)")
        }
        
        return newLog
    }
    
    // MARK: - Clear Logs
    
    static func clearAll() {
        saveLogs([])
    }
    
    // MARK: - Cross-Process Broadcast
    
    private static func broadcastUpdate(title: String? = nil) {
        var userInfo: [AnyHashable: Any] = [:]
        if let title = title {
            userInfo["title"] = title
        }
        
        // Notify any in-process observers
        NotificationCenter.default.post(
            name: didUpdateLogsNotification,
            object: nil,
            userInfo: userInfo
        )
        
        // Notify external processes (like running main app if triggered from Shortcuts background runner)
        DistributedNotificationCenter.default().postNotificationName(
            didUpdateLogsNotification,
            object: nil,
            userInfo: userInfo,
            deliverImmediately: true
        )
    }
}
