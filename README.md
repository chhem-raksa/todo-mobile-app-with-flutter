# Todo Application Project Report By Chhem Raksa and team members

- Project Title: Todo Application (Flutter)
- Student Name: 
   1. Chhem Raksa, Project Lead,
   2. Nal Monyneath, UI and UX Designer and Slide,
   3. Leang Seanghuor, Document Report
   4. Eng SokMenh, Flutter Developer,
   5. Chhim Veasna, Flutter Developer,
- Report Date: February 22, 2026
- Course: Mobile App Development

---

## 1. Executive Summary

This project is a cross-platform Todo application built with Flutter.  
The application supports:

- User registration and login
- Task create, read, update, and delete (CRUD)
- User profile editing with profile image upload
- Dark mode toggle
- API integration with `json-server`
- Local storage fallback when API is unavailable

The main goal is reliability and clean code for learning and review.  
If network/API fails, core user actions still work through local persistence.

---
## 2. Setup and Run Instructions

## 2.1 Prerequisites

- Flutter SDK installed
- Dart SDK installed
- Node.js installed (for json-server)

## 2.2 Install Dependencies

```bash
flutter pub get
```

## 2.3 Run Local API Server

From project root:

```bash
cd lib/data
json-server --watch db.json --port 3000
```

## 2.4 Run Flutter App

```bash
flutter run
```

---
## 3. Project Objectives

1. Build a functional Todo app with modern Flutter architecture.
2. Practice API integration using HTTP methods (`GET`, `POST`, `PUT`, `DELETE`).
3. Add local persistence using `SharedPreferences`.
4. Support offline-like behavior using API fallback strategy.
5. Keep code readable, maintainable, and easy for reviewer feedback.

---

## 4. Technology Stack

- Framework: Flutter (Dart SDK `^3.10.3`)
- State Management: `provider`
- HTTP Client: `http`
- Local Storage: `shared_preferences`
- Date/Time Formatting: `intl`
- Image Picker: `image_picker`
- Development Preview: `device_preview`
- Local API Server: `json-server` (against `lib/data/db.json`)

Reference: `pubspec.yaml`

---

## 5. Project Structure (Important Files)

- App entry and routes: `lib/main.dart`
- Todo state and local cache: `lib/features/models/todo_store.dart`
- API service layer: `lib/features/services/api_service.dart`
- User model: `lib/features/models/user.dart`
- User local auth storage: `lib/features/models/user_share/user_share_pre.dart`
- User provider: `lib/features/providers/user_provider.dart`
- Login UI: `lib/features/auth/login_screen.dart`
- Register UI: `lib/features/auth/register_screen.dart`
- Todo main screen: `lib/features/presentation/todo_screen.dart`
- Add task screen: `lib/features/presentation/add_task_screen.dart`
- Edit task screen: `lib/features/presentation/edit_task_screen.dart`
- Profile screen: `lib/features/profile/presentation/user_profile_screen.dart`
- Edit profile screen: `lib/features/profile/presentation/edit_profile_screen.dart`
- API test collection: `postman_collection.json`

---

## 6. Architecture Overview

### 6.1 Layers

1. Presentation Layer  
   Flutter screens and widgets handle UI and user interaction.

2. State Layer  
   `TodoStore` and `UserProvider` manage app state using `ChangeNotifier`.

3. Service Layer  
   `ApiService` handles remote API calls.

4. Local Persistence Layer  
   `SharedPreferences` stores:
   - Current user session
   - Registered local users
   - Cached tasks

### 6.2 Data Flow

UI -> Provider/Store -> Service (API) -> Local fallback/cache -> UI update

This keeps UI responsive and stable even if server is down.

---

## 7. Feature Implementation

## 7.1 Authentication

### Registration

- User enters username, email, password, confirm password.
- Optional profile image is selected from gallery.
- App tries API register first.
- If API fails, user is still registered locally.
- User data is stored in local registered users list.

Reference: `lib/features/auth/register_screen.dart`

### Login

- App validates email and password input.
- App tries API login first.
- If API login fails, app checks local registered users.
- On success, user session is saved for auto-login next launch.

Reference: `lib/features/auth/login_screen.dart`

---

## 7.2 Todo Management (CRUD)

### Load Todos

- App loads todos from API on startup.
- If API fails, app loads todos from local cache.
- Locally created offline tasks are merged and kept.

### Add Task

- App tries to create task through API.
- If API fails, task is still added locally with id format `local-<timestamp>`.
- Local cache is updated immediately.

### Update Task

- Task is updated in local state first.
- For server tasks, app attempts API update.
- For local-only tasks, no unnecessary API call is made.

### Delete Task

- Task is removed from local state immediately (for smooth Dismissible behavior).
- For server tasks, app attempts API delete in background.
- If sync fails, UI still remains consistent and a message is kept in error state.

### Clear Completed

- Completed tasks are removed locally.
- Server delete is attempted only for server-synced task ids.

Reference: `lib/features/models/todo_store.dart`

---

## 7.3 User Profile Management

- User can edit:
  - Name
  - Job/Title
  - Phone number
  - About
  - Profile image
- Profile update tries API first, then safely falls back to local update.
- Image display supports:
  - Network URL
  - Base64 local image data

References:
- `lib/features/profile/presentation/user_profile_screen.dart`
- `lib/features/profile/presentation/edit_profile_screen.dart`

---

## 8. API Integration

## 8.1 Base URL Strategy

`ApiService` selects base URL by platform:

- Web: `http://localhost:3000`
- Android emulator: `http://10.0.2.2:3000`
- Other platforms: `http://localhost:3000`

Reference: `lib/features/services/api_service.dart`

## 8.2 Endpoints Used

- `GET /users?email=...&password=...` -> login
- `GET /users?email=...` -> check duplicate email
- `POST /users` -> register
- `PUT /users/:id` -> update profile
- `GET /todos` -> fetch todos
- `POST /todos` -> create todo
- `PUT /todos/:id` -> update todo
- `DELETE /todos/:id` -> delete todo

---

## 9. Local Storage Design

## 9.1 User Storage Keys

- Current session user key: `user`
- Registered users key: `registered_users`

Reference: `lib/features/models/user_share/user_share_pre.dart`

## 9.2 Task Cache Key

- Todo cache key: `local_tasks_cache`

Reference: `lib/features/models/todo_store.dart`

---

## 10. Performance and Code Quality Improvements

The project includes practical optimizations:

1. Reduced unnecessary API calls  
   Local-only tasks skip remote update/delete requests.

2. Fast local-first UI updates  
   Delete and update reflect in UI immediately, then sync remote.

3. Local cache persistence after each mutation  
   Keeps app state stable after app restart or network failure.

4. Reduced repeated compute in widget build path  
   Reused date formatters and reused resolved image providers.

5. Cleaner state handling and validation  
   Loading flags, try/catch fallbacks, and input validation improve UX and readability.

---

## 11. Error Handling Strategy

- All major network operations use `try/catch`.
- Fallback-first behavior prevents app breaks:
  - API fail on login -> local auth fallback
  - API fail on register -> local register fallback
  - API fail on task operations -> local cache continues
  - API fail on profile update -> local profile still updates
- User-facing feedback through `SnackBar` and provider error states.

---

## 12. Security and Limitations

This is an educational project. Current limitations are expected for coursework:

1. Password is stored in plain text in local storage and json-server.
2. Authentication token is mock/fake token for demo flow.
3. No backend conflict resolution for long offline periods.
4. No encryption for profile image base64 data in local storage.

These are acceptable for student demo but not production.

---


## 13. Testing By Chhem Raksa

## 13.1 Authentication

- Register a new user with image.
- Login with API running.
- Stop API, login again using local fallback.

## 13.2 Todo CRUD

- Add task when API is running.
- Stop API and add task (should still add locally).
- Edit task (local state should update).
- Swipe delete task using Dismissible (no dismiss error).
- Restart app and verify tasks remain from local cache.

## 13.3 Profile

- Update name, title, phone, about, and image.
- Verify profile still updates when API is unavailable.

## 13.4 Theme

- Toggle dark/light mode.
- Restart app and verify theme preference is preserved with user data.

#   f l u t t e r - f i r e b a s e  
 