# UpTodo - Advanced Task & Team Management App

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

**UpTodo** is an open-source, full-featured cross-platform task, project, and team management application built with **Flutter**, **BLoC**, and **Firebase**. It provides a distraction-free, responsive experience across **Mobile (Android/iOS)**, **Tablet**, and **Web/Desktop**, offering team collaboration, Pomodoro focus tracking, interactive Kanban boards, and multi-tier task hierarchies.

---

## 🌟 Key Features

### 👥 Team Creation & Team Management
- **Create Teams**: Set custom team name, description, brand color, and representative icon.
- **Invite by Code**: Instant 6-character alphanumeric invite codes (`ABC123`) for effortless onboarding.
- **Role-Based Access Control (RBAC)**:
  - **Owner**: Full control over team settings, role assignments, invite code regeneration, and team deletion.
  - **Admin**: Can invite and manage members.
  - **Member**: Access team workspaces and collaborate on tasks.
- **Member Management**: Promote/demote member roles, remove members, or leave a team.
- **Cross-Platform Entry Points**: Accessible from the mobile **Profile** tab and the desktop/web sidebar navigation.

### 📋 Task & Project Management
- **Full CRUD Operations**: Create, view, update, delete, and duplicate tasks.
- **Hierarchy System**: 3-level organization: `Workspace` ➔ `Space` ➔ `List` ➔ `Tasks`.
- **Kanban Board**: 5 project statuses (`Backlog`, `To Do`, `In Progress`, `In Review`, `Done`) with drag-and-drop state transitions.
- **Multiple Views**: Seamlessly switch between List View and Kanban Board View.
- **Task Prioritization & Due Dates**: High, Medium, Low priority tags, due dates, and reminders.
- **Categorization**: Color-coded task categories (Work, Personal, Design, Development, etc.).
- **Subtasks & Checklists**: Break down complex tasks into manageable subtasks.
- **Search, Filter & Sort**: Filter by date, status, priority, or category; instant keyword search.

### ⏱️ Pomodoro Focus Timer
- **Customizable Intervals**: Focus session (default: 25m), Short Break (5m), Long Break (15m).
- **Task Integration**: Attach active tasks directly to focus sessions.
- **Productivity Tracking**: Track total completed sessions and focus streaks.
- **Audio/Vibration Alerts**: Clear feedback upon timer completion.

### 🤝 Real-Time Collaboration & Directory
- **Team Collaboration**: Real-time event broadcasting for comments, assignments, and status updates.
- **Assignees**: Assign tasks to registered team members and collaborators.
- **User Directory Service**: Automatically indexes registered users for instant assignee lookups.

### 🔐 Authentication & Session Persistence
- **Google Sign-In**: Powered by Google Identity Services (GIS) on Web and native Google Sign-In on mobile.
- **Email & Password**: Secure login and sign-up with Firebase Authentication.
- **Session Manager**: Persistent auto-login and splash route handling.

### 💾 Backup, Export & Restore
- **Format Support**: Export and import complete task workspaces in both **JSON** and **CSV**.
- **Data Integrity**: Preserves task titles, descriptions, due dates, priorities, and status tags.

### 🖥️ Responsive Multi-Platform UI
- **Adaptive Breakpoints**:
  - **Mobile** (`< 650px`): Bottom navigation bar, floating action sheets.
  - **Tablet** (`650px - 1024px`): Adaptive two-column split.
  - **Desktop / Web** (`≥ 1024px`): Persistent left sidebar navigation and wide Kanban viewports.
- **Design System**: Modern dark-themed UI with `flutter_screenutil` responsiveness.

### 📊 Observability & Debug Tracking
- **AppBlocObserver**: Global logging of every BLoC/Cubit event, state change, and transition.
- **Structured Debug Logs**: Tagged logs (`[TeamDataSource]`, `[TeamRepository]`, `[TeamCubit]`, `[JoinTeamDialog]`) for rapid telemetry and troubleshooting.

---

## 🏗️ Architecture & Project Structure

The project follows Clean Architecture principles with Feature-First organization and BLoC/Cubit state management:

```
lib/
├── core/
│   ├── constants/       # AppColors, AppStrings, AppStyles
│   ├── di/              # GetIt service locator setup
│   ├── routes/          # Centralized route definitions & path parsing
│   ├── services/        # SessionManager, CollaborationService, UserDirectoryService
│   └── utils/           # AppBlocObserver, DateFormatters, Helpers
├── features/
│   ├── authentication/  # Login, Register, Google Sign-In, Auth Cubits & Repos
│   ├── focus/           # Pomodoro timer cubit, state, and focus view
│   ├── home/            # Home view, desktop sidebar, bottom navigation
│   ├── profile/         # Profile view, settings, preferences
│   ├── task/            # Task CRUD, Hierarchy, Kanban Board, Categories
│   ├── team/            # Team creation, invite codes, RBAC, member management
│   │   ├── data/
│   │   │   ├── datasources/  # Firestore team remote data source
│   │   │   ├── models/       # TeamModel, TeamMemberModel
│   │   │   └── repos/        # TeamRepository & implementation
│   │   └── presentation/
│   │       ├── manager/      # TeamCubit & TeamState
│   │       ├── views/        # TeamsHubView, TeamDetailView
│   │       └── widgets/      # CreateTeamSheet, JoinTeamDialog, InviteCodeCard, MemberTile
│   └── workspace/       # Workspace, Space, and List hierarchy models
├── firebase_options.dart
├── main.dart            # Application entry point
└── task_manager_app.dart
```

---

## 🛠️ Tech Stack & Dependencies

| Category | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev) (v3.24+) |
| **Language** | [Dart](https://dart.dev) (v3.5+) |
| **State Management** | [flutter_bloc](https://pub.dev/packages/flutter_bloc) |
| **Backend & Auth** | [Firebase Core](https://pub.dev/packages/firebase_core), [Firebase Auth](https://pub.dev/packages/firebase_auth), [Cloud Firestore](https://pub.dev/packages/cloud_firestore) |
| **Dependency Injection** | [get_it](https://pub.dev/packages/get_it) |
| **UI & Icons** | [flutter_screenutil](https://pub.dev/packages/flutter_screenutil), [iconsax](https://pub.dev/packages/iconsax) |
| **Storage & Caching** | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| **Google Sign-In** | [google_sign_in](https://pub.dev/packages/google_sign_in), [google_sign_in_web](https://pub.dev/packages/google_sign_in_web) |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (`>=3.24.0`)
- [Dart SDK](https://dart.dev/get-dart) (`>=3.5.0`)
- A Firebase project with **Authentication** and **Cloud Firestore** enabled

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/task_manager_app.git
cd task_manager_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration
Make sure your Firebase project credentials are configured:
```bash
# Optional: re-generate default options if using a new Firebase project
flutterfire configure
```

Ensure your `firestore.rules` are deployed:
```bash
firebase deploy --only firestore:rules
```

### 4. Run the Application

#### Flutter Web
```bash
flutter run -d chrome
```

#### macOS Desktop
```bash
flutter run -d macos
```

#### Android
```bash
flutter run -d android
```

#### iOS
```bash
flutter run -d ios
```

---

## 🧪 Testing & Code Quality

Run static analysis to ensure zero warnings or errors:
```bash
dart analyze --fatal-infos
```

Run the automated test suite (Unit & Widget tests):
```bash
flutter test
```

### Test Coverage Highlights:
- **`team_feature_test.dart`**: Validates TeamModel serialization, 6-character code generation, and TeamRole JSON mapping.
- **`focus_timer_test.dart`**: Tests Pomodoro countdown intervals, break transitions, and settings persistence.
- **`hierarchy_and_collaboration_test.dart`**: Tests Workspace/Space/List filtering, 5-column Kanban transitions, and real-time events.
- **`cloud_sync_and_assignee_test.dart`**: Tests User Directory registration and cross-device session synchronization.
- **`task_backup_test.dart`**: Tests JSON & CSV import/export data fidelity.
- **`session_manager_test.dart`**: Tests onboarding flow and session persistence across cold restarts.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
