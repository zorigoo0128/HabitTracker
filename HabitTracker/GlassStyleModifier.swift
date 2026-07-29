//
//  GlassStyleModifier.swift
//  HabitTracker
//
//  Created by Batzorig Byambabaatar on 2026.07.26.
//

import SwiftUI

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.15
    var borderColor: Color = Color.white.opacity(0.2)
    var borderWidth: CGFloat = 1
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        borderColor,
                                        borderColor.opacity(0.3),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: borderWidth
                            )
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
            )
    }
}

struct GlassPillModifier: ViewModifier {
    var isSelected: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(LinearGradient(colors: [Color.emeraldAccent.opacity(0.4), Color.cyanAccent.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Material.ultraThinMaterial))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(
                                isSelected ? Color.emeraldAccent.opacity(0.6) : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 1.5 : 0.8
                            )
                    )
                    .shadow(color: isSelected ? Color.emeraldAccent.opacity(0.25) : Color.clear, radius: 8, x: 0, y: 3)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, opacity: Double = 0.15, borderColor: Color = Color.white.opacity(0.2), borderWidth: CGFloat = 1) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, opacity: opacity, borderColor: borderColor, borderWidth: borderWidth))
    }
    
    func glassPill(isSelected: Bool = false) -> some View {
        self.modifier(GlassPillModifier(isSelected: isSelected))
    }
}

extension ShapeStyle where Self == Color {
    static var emeraldAccent: Color { Color(red: 0.2, green: 0.88, blue: 0.58) }
    static var cyanAccent: Color { Color(red: 0.15, green: 0.78, blue: 0.98) }
    static var indigoAccent: Color { Color(red: 0.45, green: 0.4, blue: 0.95) }
    static var orangeAccent: Color { Color(red: 1.0, green: 0.55, blue: 0.2) }
    static var purpleAccent: Color { Color(red: 0.7, green: 0.35, blue: 0.95) }
}

extension Color {
    static let glassBackground = Color("GlassBackground", bundle: nil)
    static let emeraldAccent = Color(red: 0.2, green: 0.88, blue: 0.58)
    static let cyanAccent = Color(red: 0.15, green: 0.78, blue: 0.98)
    static let indigoAccent = Color(red: 0.45, green: 0.4, blue: 0.95)
    static let orangeAccent = Color(red: 1.0, green: 0.55, blue: 0.2)
    static let purpleAccent = Color(red: 0.7, green: 0.35, blue: 0.95)
    
    static func heatmapColor(for level: Int) -> Color {
        switch level {
        case 0:
            return Color.white.opacity(0.06)
        case 1:
            return Color(red: 0.1, green: 0.45, blue: 0.32).opacity(0.6)
        case 2:
            return Color(red: 0.15, green: 0.65, blue: 0.42).opacity(0.85)
        case 3:
            return Color(red: 0.2, green: 0.82, blue: 0.52)
        case 4:
            return Color(red: 0.25, green: 0.98, blue: 0.62)
        default:
            return Color.white.opacity(0.06)
        }
    }
}
