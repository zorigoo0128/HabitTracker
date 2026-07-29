//
//  ContentView.swift
//  HabitTracker
//
//  Created by Batzorig Byambabaatar on 2026.07.26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var habitStore: HabitStore
    
    var body: some View {
        ZStack {
            // Ambient Glass Background Gradients
            GlassBackgroundView()
            
            VStack(spacing: 0) {
                // Top Header Bar
                HeaderView()
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                
                // Toast Message Banner
                if let toastMessage = habitStore.recentAddedToastMessage {
                    ToastBannerView(message: toastMessage)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Scrollable Content Body
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // GitHub-Style Heatmap Grid Card
                        ContributionHeatmapView()
                        
                        // Today's Activity & Registers Card
                        TodayActivityView()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 160) // Spacing for bottom prompt & recommend views
                }
            }
            
            // Bottom Anchored Recommendations + AI Prompt Input Bar
            VStack(spacing: 10) {
                Spacer()
                
                VStack(spacing: 10) {
                    // Quick Recommendation Pills
                    QuickRecommendView()
                        .padding(.horizontal, 16)
                    
                    // AI Prompt Input Bar
                    AIPromptInputBar()
                        .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .mask(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.8), .black],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Subviews

struct HeaderView: View {
    @EnvironmentObject var habitStore: HabitStore
    @Environment(\.openSettings) private var openSettings
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.emeraldAccent, .cyanAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 38, height: 38)
                        .shadow(color: Color.emeraldAccent.opacity(0.4), radius: 8)
                    
                    Image(systemName: "bolt.shield.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.black)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Habit Tracker")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("Glass UI Edition")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.cyanAccent)
                }
            }
            
            Spacer()
            
            // Stats Badge
            HStack(spacing: 12) {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(habitStore.totalLogsCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.emeraldAccent)
                    Text("Total Logs")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(habitStore.longestStreak)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.orangeAccent)
                    Text("Best Streak")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .glassCard(cornerRadius: 14)

            Button {
                openSettings()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
    }
}

struct ToastBannerView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.emeraldAccent)
                .font(.subheadline)
            
            Text(message)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.emeraldAccent.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.emeraldAccent.opacity(0.3), radius: 8)
        )
    }
}

struct GlassBackgroundView: View {
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.06, blue: 0.09)
                .ignoresSafeArea()
            
            // Glowing Ambient Light Circles
            Circle()
                .fill(Color.emeraldAccent.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -120, y: -250)
            
            Circle()
                .fill(Color.indigoAccent.opacity(0.18))
                .frame(width: 350, height: 350)
                .blur(radius: 90)
                .offset(x: 140, y: -80)
            
            Circle()
                .fill(Color.cyanAccent.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -80, y: 300)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HabitStore())
    }
}
