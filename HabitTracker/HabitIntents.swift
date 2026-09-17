//
//  HabitIntents.swift
//  HabitTracker
//
//  Created by Antigravity on 2026.09.14.
//

import AppIntents
import Foundation

enum HabitIntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case emptyTitle
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .emptyTitle:
            return "Habit title cannot be empty."
        }
    }
}

struct LogHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Habit"
    static var description = IntentDescription("Record a completed habit in HabitTracker.")
    static var openAppWhenRun: Bool = false
    
    @Parameter(
        title: "Habit Title",
        description: "The name or description of the habit completed",
        requestValueDialog: IntentDialog("What habit did you complete?")
    )
    var title: String
    
    @Parameter(
        title: "Category",
        description: "Category of the habit. If left empty, it will be automatically inferred.",
        default: nil
    )
    var category: HabitCategory?
    
    @Parameter(
        title: "Note",
        description: "Optional note or comment for this habit log",
        default: nil
    )
    var note: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$title)") {
            \.$category
            \.$note
        }
    }
    
    init() {}
    
    init(title: String, category: HabitCategory? = nil, note: String? = nil) {
        self.title = title
        self.category = category
        self.note = note
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw HabitIntentError.emptyTitle
        }
        
        let targetCategory = category ?? HabitCategory.infer(from: trimmedTitle)
        let log = await HabitStorage.appendLog(title: trimmedTitle, category: targetCategory, note: note)
        
        let message = "Logged \"\(log.title)\" under \(targetCategory.rawValue)"
        return .result(
            value: message,
            dialog: IntentDialog(stringLiteral: message)
        )
    }
}

struct HabitShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogHabitIntent(),
            phrases: [
                "Log a habit in \(.applicationName)",
                "Log habit in \(.applicationName)",
                "Record habit in \(.applicationName)",
                "Track habit in \(.applicationName)"
            ],
            shortTitle: "Log Habit",
            systemImageName: "checkmark.circle.fill"
        )
    }
}
