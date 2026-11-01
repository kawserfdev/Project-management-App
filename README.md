# Task Manager App

Task Manager App is an open-source Flutter application designed to help users manage their tasks efficiently and collaboratively. The app includes robust features such as user authentication, task management, real-time updates across devices, calendar integration, and state management. It is designed to be free and ad-free, ensuring a seamless user e perience without distractions.

## 🌟 Features Overview

### ✅ User Features

- [x] **User Authentication**
  - [x] Sign up, login, logout (Email/Password, Google, Firebase)
  - [x] Two-Factor Authentication
  - [x] Profile management
  - [ ] Social logins (Apple, Microsoft)
  
- [x] **Task Management**
  - [x] Task creation, reading, updating, deleting (CRUD)
  - [x] Task prioritization (High, Medium, Low)
  - [x] Task categorization (Work, Personal, etc.)
  - [x] Subtasks management
  - [x] Task due dates and reminders
  - [x] Task status tracking (To Do, In Progress, Done)
  - [x] Bulk actions on tasks (complete, delete)
  
- [x] **Search and Filter**
  - [x] Search tasks by keyword
  - [x] Filter tasks by date, category, and status
  - [x] Sort tasks by due date, priority, etc.

- [ ] **Real-Time Updates**
  - [ ] Sync tasks in real-time across devices
  - [ ] Real-time task collaboration

- [x] **Notifications**
  - [ ] Push notifications for task reminders
  - [x] In-app notifications
  - [ ] Email notifications for task updates

- [x] **Calendar Integration**
  - [ ] Sync tasks with Google Calendar/Outlook
  - [x] Calendar view for task management

- [x] **Time Tracking**
  - [x] Pomodoro timer for focused task work
  - [x] Log time spent on tasks
  - [x] Generate time reports for tasks
  
- [x] **Onboarding**
  - [x] Interactive onboarding for new users
  - [x] Step-by-step guide through key app features
  
- [x] **Settings**
  - [x] Theme customization (Light/Dark mode)
  - [x] Manage notification preferences
  - [x] Account management (Change password, update profile)

- [x] **Advanced Analytics**
  - [x] Insights into task completion and productivity trends
  - [x] Reports on task performance

- [ ] **Creator Features**
  - [ ] Schedule and post to LinkedIn directly from the app
  - [ ] Publish videos or updates to YouTube
  - [ ] Task-related analytics (likes, comments, views, etc.)

- [x] **Collaboration**
  - [x] Assign tasks to team members
  - [x] Add comments to tasks for discussion
  - [ ] Real-time collaboration and updates on tasks

- [x] **Profile Management**
  - [x] View and update user profile information
  - [x] Change password
  - [x] Customize avatar and profile settings
  
- [x] **Error/Message Handling**
  - [x] Error messages for failed actions
  - [x] Confirmation dialogs for critical actions

- [x] **Multi-language Support**
  - [x] Language selection for the app
  - [ ] Localized content for different regions

- [ ] **Accessibility Settings**
  - [ ] Text size adjustments for readability
  - [ ] High contrast mode for improved visibility
  - [ ] Screen reader support for visually impaired users

- [x] **Offline Access**
  - [x] Access and manage tasks offline
  - [x] Sync automatically when reconnected
  
- [x] **Data Backup and Restore**
  - [x] Backup of user tasks and data (JSON & CSV export)
  - [x] Restore tasks and settings from backup (JSON & CSV import)
  
- [x] **Dark Mode**
  - [x] Enable Dark Mode
  - [ ] Schedule Dark Mode automatically based on time of day
  
---

### 🔧 Dev Features

- [ ] **CI/CD Setup**
  - [ ] GitHub Actions for automated build and test pipelines
  - [ ] Fastlane integration for automated deployments

- [x] **Flavors**
  - [x] Separate app environments for Development and Production

- [x] **State Management**
  - [x] Bloc for centralized state management
  - [x] Real-time state updates across the app

- [x] **Database Management**
  - [ ] Cloud database (e.g., Firebase Firestore, Supabase) for storing tasks
  - [x] Local storage (SQLite/Shared Preferences) for offline persistence

- [ ] **Real-Time Database**
  - [ ] Sync data in real-time between devices

- [ ] **Pagination**
  - [ ] Efficient task fetching via pagination
  - [ ] Lazy loading and infinite scrolling

- [ ] **Cloud Functions**
  - [ ] Serverless backend logic for automation (e.g., scheduling posts, notifications)

- [ ] **Push Notifications Integration**
  - [ ] FCM (Firebase Cloud Messaging) for push notifications
  - [ ] Support for local notifications

- [ ] **API Integrations**
  - [ ] OAuth2 integration for third-party services (LinkedIn, YouTube)
  - [ ] Google Calendar API integration for syncing tasks

- [x] **Unit Testing**
  - [x] Unit tests for key functionality & widget test coverage
  - [ ] Continuous integration with test coverage reporting

- [ ] **Cloud Storage**
  - [ ] Store and retrieve media (task attachments, videos) from cloud storage

- [ ] **Analytics Backend**
  - [ ] Integration with Firebase Analytics for tracking user behavior

- [ ] **Error Handling and Logging**
  - [ ] Centralized error handling using Sentry/Firebase Crashlytics
  - [ ] Activity logging for debugging and monitoring

- [x] **Multi-Platform Support**
  - [x] Optimized builds for Android, iOS, and Flutter Web
  - [x] Responsive layout adaptions across Mobile (<650px), Tablet (650px-1024px), and Desktop (>=1024px)
  - [x] 5-Column Kanban Board with horizontal scroll and drag-and-drop on Web

- [ ] **Custom Widgets**
  - [ ] Home screen widgets for quick task view or reminders

- [ ] **Localization Tools**
  - [ ] Tools to manage multiple languages

- [x] **Data Import/Export**
  - [x] Import tasks from CSV/JSON
  - [x] Export reports and tasks to formats like CSV and JSON

- [ ] **Performance Optimization**
  - [ ] Caching, lazy loading, and memory management optimizations

- [ ] **DevOps Features**
  - [ ] Scheduled cloud backups
  - [ ] Regular performance monitoring and optimization

---

## 🚀 Running and Building

### Flutter Web
Run in Chrome development mode:
```bash
flutter run -d chrome -t lib/main_development.dart
```

Build production Web bundle:
```bash
flutter build web -t lib/main_production.dart --no-tree-shake-icons
```
Output bundle: `build/web/`

### Android
Build APK:
```bash
# Development
flutter build apk --flavor development -t lib/main_development.dart

# Production
flutter build apk --flavor production -t lib/main_production.dart
```

---

## 🛠 Contributing

We welcome contributions to the **Task Manager App**! Please follow these guidelines for contributing:

1. **Fork the repository**
2. **Create a new branch**: `git checkout -b feature-branch`
3. **Make your changes** and commit: `git commit -m 'Add some feature'`
4. **Push to the branch**: `git push origin feature-branch`
5. **Create a Pull Request**: We'll review and merge the changes

---

## 📩 Contact

If you have any questions or suggestions, feel free to open an issue or contact us directly. We're always open to feedback and improvements!

Happy coding! 🎉
# Project-management-App
