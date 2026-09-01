# ExpenseTracker

A Flutter expense tracking app. Log spending by category, see the current month’s total, and break it down with a pie chart.

## Tech stack

- Flutter (Dart)
- Riverpod for state
- sqflite (SQLite) for local persistence
- fl_chart for the category pie chart
- Clean architecture: `lib/data`, `lib/domain`, `lib/presentation`

Package name: `com.ahmedelemey.expensetracker`

## Setup

```bash
flutter pub get
flutter run
```

Requires the Flutter SDK (this repo targets Dart `^3.9.2`).
