# Flutter Learning Portfolio

This repository documents my journey of learning Flutter from scratch and building real projects step by step.

I started with prior programming knowledge, but no previous Flutter, Dart, Android Studio, or emulator experience. The goal of this repository is to show consistent learning progress, practical implementation, clean project structure, and portfolio-ready Flutter apps.

## Current Status

| Project  | Status           | Description                                                                                                                             |
| -------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| TaskNest | Completed v0.1.0 | A polished task management app built with Flutter, Riverpod, go_router, local storage, filtering, sorting, search, dark mode, and tests |

## Repository Structure

```text
flutter_learning/
  README.md
  projects/
    daily_tasks/
      README.md
      lib/
      test/
      screenshots/
```

## Projects

## 1. TaskNest

TaskNest is a Flutter productivity app built as a portfolio showcase project. It helps users manage daily tasks with priorities, categories, due dates, search, filters, sorting, local persistence, and dark mode.

### Features

* Add tasks
* Edit tasks
* Delete tasks
* Mark tasks as completed
* View task details
* Add descriptions
* Set priorities
* Assign categories
* Add optional due dates
* Search tasks
* Filter by All, Active, and Done
* Sort by newest, oldest, priority, and due date
* Clear completed tasks
* Clear all tasks from settings
* Light and dark mode
* Local persistence
* Widget tests

### Tech Stack

* Flutter
* Dart
* Riverpod
* go_router
* shared_preferences
* Material 3

### Screenshots

Screenshots are available inside:

```text
projects/daily_tasks/screenshots/
```

Recommended screenshot files:

```text
home.png
add_task.png
details.png
settings.png
dark_mode.png
```

### Project Folder

```text
projects/daily_tasks/
```

### Project README

See the full project documentation here:

```text
projects/daily_tasks/README.md
```

## Learning Timeline

| Day   | Progress                                                                                                                                                                                  |
| ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Day 1 | Installed Flutter tools, configured emulator, created first Flutter app, learned hot reload, widgets, StatefulWidget, setState, and basic Git workflow                                    |
| Day 2 | Added task model, reusable widgets, local persistence, navigation, tests, and GitHub commits                                                                                              |
| Day 3 | Upgraded the app into TaskNest, added Riverpod, go_router, feature-based architecture, search, sorting, filtering, details screen, settings screen, dark mode, and release build workflow |

## Skills Demonstrated

This repository demonstrates practical knowledge of:

* Flutter project setup
* Dart fundamentals
* Android emulator setup
* VS Code Flutter workflow
* Material 3 UI
* Widget composition
* Stateful and reactive UI
* Riverpod state management
* go_router navigation
* Local storage
* JSON serialization
* Feature-based folder structure
* Form validation
* Search, filter, and sort logic
* Confirmation dialogs
* Snackbars
* Dark mode
* Widget testing
* Flutter analyze
* Android APK release build
* Git and GitHub workflow

## How to Run a Project

Go to the project folder:

```bash
cd projects/daily_tasks
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run on a specific Android emulator:

```bash
flutter devices
flutter run -d emulator-5554
```

## Testing

From the project folder:

```bash
flutter analyze
flutter test
```

Expected result:

```text
No issues found
All tests passed
```

## Build APK

From the project folder:

```bash
flutter build apk --release
```

The APK will be generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Compiled APK files should not be committed into this repository. They should be uploaded through GitHub Releases.

## Releases

TaskNest v0.1.0 is available here:

[Download TaskNest v0.1.0](https://github.com/jabir02/flutter_learning/releases/tag/tasknest-v0.1.0)

The Android APK is attached to the GitHub Release page.
```

## Why This Repository Exists

This repository is not only for storing code. It is a record of my Flutter learning process and my ability to build complete mobile apps from setup to release.

It shows:

* Learning consistency
* Practical implementation
* GitHub workflow
* Debugging progress
* Project documentation
* Portfolio-level Flutter development

## Future Projects

Planned future Flutter projects:

| Project                | Purpose                                                        |
| ---------------------- | -------------------------------------------------------------- |
| Weather App            | API integration, loading states, error states, and clean UI    |
| Expense Tracker        | Charts, data modeling, local database, and financial summaries |
| Notes App              | Rich text, search, categories, and offline storage             |
| Habit Tracker          | Calendar UI, streaks, analytics, and notifications             |
| Full Stack Flutter App | Authentication, backend API, cloud database, and deployment    |

## Current Focus

The current focus is to use TaskNest as the first polished Flutter portfolio project, then move toward a more complex app with API integration, authentication, and scalable architecture.

## Author

Built as part of my Flutter learning and mobile app development portfolio.
