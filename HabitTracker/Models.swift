//
//  Models.swift
//  HabitTracker
//
//  Created by Batzorig Byambabaatar on 2026.07.26.
//

import Foundation
import SwiftUI

enum HabitCategory: String, Codable, CaseIterable, Identifiable {
    case learning = "Learning"
    case fitness = "Fitness"
    case health = "Health"
    case mindset = "Mindset"
    case productivity = "Productivity"
    case general = "General"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .learning: return "book.fill"
        case .fitness: return "figure.run"
        case .health: return "heart.fill"
        case .mindset: return "brain.head.profile"
        case .productivity: return "checkmark.seal.fill"
        case .general: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .learning: return .indigoAccent
        case .fitness: return .orangeAccent
        case .health: return .emeraldAccent
        case .mindset: return .purpleAccent
        case .productivity: return .cyanAccent
        case .general: return .white.opacity(0.8)
        }
    }
}

struct HabitLog: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var category: HabitCategory
    var note: String?
    var score: Int
    
    init(id: UUID = UUID(), title: String, date: Date = Date(), category: HabitCategory = .general, note: String? = nil, score: Int = 1) {
        self.id = id
        self.title = title
        self.date = date
        self.category = category
        self.note = note
        self.score = score
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var dateKey: String {
        HabitLog.dateFormatter.string(from: date)
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

struct HabitPreset: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let icon: String
    let category: HabitCategory
    
    static let defaultPresets: [HabitPreset] = [
        HabitPreset(title: "I did some homework", icon: "books.vertical.fill", category: .learning),
        HabitPreset(title: "Did Duolingo lesson", icon: "owl.fill", category: .learning),
        HabitPreset(title: "Drank 2L water", icon: "drop.fill", category: .health),
        HabitPreset(title: "30-min workout", icon: "figure.cross.training", category: .fitness),
        HabitPreset(title: "Meditated 10 min", icon: "leaf.fill", category: .mindset),
        HabitPreset(title: "Read 20 pages", icon: "book.pages.fill", category: .learning),
        HabitPreset(title: "Coded for 1 hour", icon: "laptopcomputer", category: .productivity),
        HabitPreset(title: "Walked 8,000 steps", icon: "figure.walk", category: .fitness)
    ]
}

struct DailyContribution: Identifiable, Equatable {
    var id: String { dateKey }
    let date: Date
    let dateKey: String
    let count: Int
    let level: Int // 0, 1, 2, 3, 4
}
