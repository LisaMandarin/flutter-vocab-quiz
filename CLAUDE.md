# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile vocabulary quiz application that allows users to create, study, and quiz themselves on custom word lists. The app integrates with Firebase for authentication and data storage.

## Common Development Commands

**Build and Run:**
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app (requires Xcode on macOS)

**Testing and Analysis:**
- `flutter test` - Run unit and widget tests
- `flutter analyze` - Static code analysis using the configuration in analysis_options.yaml
- `flutter pub get` - Install dependencies from pubspec.yaml
- `flutter clean` - Clean build artifacts

**Firebase:**
- Requires firebase_options.dart file (auto-generated, do not edit manually)
- Uses Firebase Authentication and Cloud Firestore

## Code Architecture

**Directory Structure:**
- `lib/main.dart` - App entry point with Firebase initialization and auth state management
- `lib/services/` - Business logic layer
  - `auth_services.dart` - Firebase Authentication wrapper using ValueNotifier pattern
  - `firestore_services.dart` - Firestore database operations using ValueNotifier pattern
- `lib/views/` - UI layer
  - `pages/` - Full-screen pages (home, login, quiz, practice, etc.)
  - `components/` - Reusable widgets (flipcard, input, appbar, etc.)
- `lib/data/` - Data models and styling
  - `classes.dart` - Data classes
  - `vocabList.dart` - Vocabulary list definitions
  - `styles.dart` - App-wide styling
- `lib/utils/` - Utility functions (dialogs, snackbars, etc.)

**Key Patterns:**
- ValueNotifier pattern for state management (authService, firestore)
- StreamBuilder for reactive UI based on auth state
- Firebase services wrapped in singleton-like ValueNotifier instances
- Material Design components with custom styling

**Authentication Flow:**
- Unauthenticated users see HomePage
- Authenticated users see SettingPage as home
- Auth state changes trigger UI rebuilds via StreamBuilder in main.dart

**Data Management:**
- Word lists stored in Firestore 'word_lists' collection
- User profiles in 'users' collection
- All operations require authentication
- Real-time updates through Firestore listeners

## Firebase Configuration

The app uses Firebase for backend services:
- Authentication: Email/password sign-in with password reset
- Firestore: Document-based storage for users and word lists
- Configuration files: `firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`

## Asset Management

Images and animations are stored in:
- `assets/images/` - Background images, logos, icons
- `assets/lotties/` - Lottie animation files

## Current Features

- User registration and authentication
- Custom vocabulary list creation and management
- Flashcard-style practice mode with flip animations
- Quiz mode with scoring
- Word list sharing and management
- User profiles and settings