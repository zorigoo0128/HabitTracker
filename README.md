# HabitTracker (macOS)

<p align="center">
  <img src="Screenshot.png" alt="HabitTracker macOS App" width="850" style="border-radius: 12px; box-shadow: 0 12px 32px rgba(0,0,0,0.35);" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2014.0%2B-000000?logo=apple&style=flat-square" alt="Platform: macOS" />
  <img src="https://img.shields.io/badge/Swift-5.0%2B-FA7343?logo=swift&logoColor=white&style=flat-square" alt="Swift 5.0+" />
  <img src="https://img.shields.io/badge/UI-SwiftUI%20Glassmorphism-blue?style=flat-square" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/Extension-WidgetKit-7A57D1?style=flat-square" alt="WidgetKit" />
  <img src="https://img.shields.io/badge/Automation-AppIntents%20%2F%20Shortcuts-FF2D55?style=flat-square" alt="AppIntents" />
  <img src="https://img.shields.io/badge/License-Apache%202.0-green?style=flat-square" alt="License: Apache 2.0" />
</p>

A native macOS habit tracking application built with **SwiftUI**, **WidgetKit**, and **AppIntents**. Designed with a modern glassmorphic dark aesthetic, it features a GitHub-style activity heatmap, smart natural-language habit logging, desktop widgets, and deep **macOS Shortcuts** integration.

---

## Features

- 🟩 **GitHub-Style Contribution Heatmap**:
  - Interactive grid displaying weekly and monthly habit activity over the last 90+ days.
  - Dynamic 5-level intensity gradient based on daily completion counts.
  - Click any square to view recorded activities with exact timestamps and categories.
  - Real-time current streak and all-time best streak tracking.

- ⚡ **Natural Language / AI Prompt Bar**:
  - Log habits quickly by typing naturally (e.g. *"Read 20 pages"*, *"Drank 2L water"*, *"30 min gym workout"*).
  - Built-in heuristic engine automatically infers the category and assigns appropriate icons and colors.

- 🪄 **macOS Shortcuts & Automation (AppIntents)**:
  - Drag-and-drop **"Log Habit"** action available directly in the macOS **Shortcuts** app.
  - Supports input parameters: `Habit Title` (required), `Category` (optional dropdown), and `Note` (optional).
  - Background execution (`openAppWhenRun = false`) allows quick triggers from Siri, Spotlight, Raycast, or automated schedules without interrupting your workflow.
  - Real-time UI synchronization: running a shortcut instantly refreshes the active macOS window and shows an animated confirmation toast banner.

- 🖥️ **macOS Desktop & Notification Center Widgets**:
  - Companion **WidgetKit** extension supporting Small, Medium, and Large widgets.
  - Displays your ongoing challenge heatmap and current streak right on your desktop.
  - Communicates via a shared App Group (`group.com.zorigoo.HabitTracker`) and updates immediately whenever habits are logged.

- 🎨 **Refined Glassmorphic Design**:
  - Dark ambient glow backgrounds, blurred materials (`.ultraThinMaterial`), subtle border gradients, and spring animations.
  - Category color coding: **Learning** (Indigo), **Fitness** (Orange), **Health** (Emerald), **Mindset** (Purple), **Productivity** (Cyan), and **General** (White).

- 🏷️ **Quick Recommends & Filtering**:
  - One-tap preset chips for common daily habits.
  - Filter today's activity stream by category or view all completed tasks.

---

## Architecture & Codebase Overview

The project is structured with a reactive **SwiftUI + ObservableObject (MVVM-lite)** pattern and modular target separation:

```
HabitTracker/
├── HabitTracker/                  # Main macOS Application Target
│   ├── HabitTrackerApp.swift      # @main App entry point & Settings scene
│   ├── Models.swift               # Domain models (HabitLog, HabitCategory, HabitPreset, DailyContribution)
│   ├── HabitStorage.swift         # App Group persistence, cross-process broadcast, and WidgetKit reload
│   ├── HabitStore.swift           # Central ObservableObject managing app state, streaks, and heatmap grid
│   ├── HabitIntents.swift         # AppIntents integration (LogHabitIntent & HabitShortcutsProvider)
│   ├── ContentView.swift          # Main dashboard container and header
│   ├── ContributionHeatmapView.swift # Interactive contribution heatmap matrix and inspector
│   ├── TodayActivityView.swift    # Today's activity list with category filter chips
│   ├── AIPromptInputBar.swift     # Natural language input bar with auto-inference
│   ├── QuickRecommendView.swift   # Quick habit preset chips
│   ├── AppSettingsView.swift      # Native macOS Settings pane (stats & data clear)
│   ├── GlassStyleModifier.swift   # Reusable glassmorphic modifiers, styles, and color palette
│   └── HabitTracker.entitlements  # App Group entitlement (group.com.zorigoo.HabitTracker)
│
└── HabitWidget/                   # macOS WidgetKit Extension Target
    ├── HabitWidget.swift          # Widget timeline provider and responsive heatmap layout
    ├── HabitWidgetBundle.swift    # Widget bundle entry point
    └── HabitWidget.entitlements   # App Group entitlement for data sharing
```

---

## Using with macOS Shortcuts

### Drag & Drop into a Shortcut

1. Build and run **HabitTracker** once on your Mac to register AppIntents with the system.
2. Open the **Shortcuts** app on macOS (`/System/Applications/Shortcuts.app`).
3. Click **`+`** to create a new shortcut.
4. In the right-hand **Actions** panel, search for **`Habit Tracker`** or **`Log Habit`**.
5. Drag the **Log Habit** action onto your workflow canvas.
6. Configure the action:
   - **Habit Title**: Pass text directly, or connect from previous actions (such as *Ask for Input*, *Dictate Text*, or *Clipboard*).
   - **Category** *(Optional)*: Select a category from the dropdown menu (Learning, Fitness, Health, Mindset, Productivity, General), or leave blank for automatic inference.
   - **Note** *(Optional)*: Add additional context.

### Example Shortcut Ideas

- **Morning Routine**: Run a shortcut at 8:00 AM that asks what you want to achieve today, sets a reminder, and logs your morning water/meditation habit.
- **Raycast / Alfred Hotkey**: Trigger a quick shortcut via hotkey to log a habit from anywhere without opening the app window.
- **Siri Voice Command**: Say *"Log a habit in Habit Tracker"* or *"Track habit in Habit Tracker"*.

---

## Getting Started

### Prerequisites

- **macOS 14.0+** (Sonoma) or **macOS 15.0+** (Sequoia)
- **Xcode 16.0+**
- Active Apple Developer account (for custom App Group code signing)

### Build & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/zorigoo0128/HabitTracker.git
   cd HabitTracker
   ```

2. Open the project in Xcode:
   ```bash
   open HabitTracker.xcodeproj
   ```

3. Configure Signing & Capabilities:
   - Select the `HabitTracker` target -> **Signing & Capabilities**.
   - Select your personal team for Development Signing.
   - Ensure the App Group `group.com.zorigoo.HabitTracker` is enabled for both `HabitTracker` and `HabitWidgetExtension` targets (or change it to your own custom bundle prefix if re-signing).

4. Select the **HabitTracker** scheme and press **`⌘ + R`** to build and run.

---

## License

This project is licensed under the **Apache License 2.0**. See the [LICENSE](LICENSE) file for complete terms and details.
