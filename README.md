# My Book Library

[![Project Status: In Development](https://img.shields.io/badge/status-in%20development-yellowgreen.svg)](https://shields.io/)

A mobile application for Android designed for book lovers. It provides a simple, centralized tool to manage a personal library, track reading progress, and visualize reading habits.

## Table of Contents

- [My Book Library](#my-book-library)
  - [Table of Contents](#table-of-contents)
  - [Project Description](#project-description)
    - [Key Features](#key-features)
  - [Tech Stack](#tech-stack)
  - [Getting Started Locally](#getting-started-locally)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
  - [Available Scripts](#available-scripts)
    - [Development Scripts](#development-scripts)
    - [Release Scripts](#release-scripts)
  - [API Documentation](#api-documentation)
    - [Genre API](#genre-api)
  - [Project Scope](#project-scope)
    - [In Scope (MVP)](#in-scope-mvp)
    - [Out of Scope (Post-MVP)](#out-of-scope-post-mvp)
  - [Project Status](#project-status)
  - [License](#license)

## Project Description

My Book Library is a Flutter-based mobile application for the Android platform that aims to solve the common problem of managing a diverse collection of physical and digital books. It offers an intuitive platform for cataloging books, monitoring reading progress through sessions, and analyzing reading activity. By integrating with the Google Books API, the app automates the process of adding new books, making library management quick and easy.

### Key Features

-   **User Authentication**: Secure registration and login using Supabase Auth.
-   **Library Management**: Add books manually or by scanning an ISBN, which fetches data from the Google Books API. Edit and delete books from your library.
-   **Progress Tracking**: Assign statuses ("Unread", "In Progress", "Read") to books and track reading progress by starting/stopping reading sessions.
-   **Data Visualization**: View your library in a grid format, filter by status or genre, and review the history of reading sessions for each book.
-   **Onboarding**: A simple tutorial for new users to get acquainted with the app's main features.
-   **Notifications**: Receive push notifications for reading sessions that have been active for an extended period.

## Tech Stack

-   **Frontend**: Flutter & Dart
-   **Backend-as-a-Service (BaaS)**: Supabase
-   **Database**: PostgreSQL (via Supabase)
-   **Authentication**: Supabase Auth
-   **CI/CD**: GitHub Actions

## Getting Started Locally

To get a local copy up and running, follow these simple steps.

### Prerequisites

-   Flutter SDK: Make sure you have the Flutter SDK installed. For installation instructions, see the [official Flutter documentation](https://flutter.dev/docs/get-started/install).
-   An editor like VS Code or Android Studio with the Flutter plugin.

### Installation

1.  Clone the repository:
    ```sh
    git clone https://github.com/your-username/my_book_library.git
    ```
2.  Navigate to the project directory:
    ```sh
    cd my_book_library
    ```
3.  Install dependencies:
    ```sh
    flutter pub get
    ```
4.  Run the application:
    ```sh
    flutter run
    ```

## Available Scripts

### Development Scripts

-   `flutter run`: Compiles and runs the application on a connected device or emulator.
-   `flutter test`: Runs the unit and widget tests for the project.
-   `flutter analyze`: Analyzes the project's Dart code for potential errors.
-   `dart format .`: Formats all Dart files in the project according to the recommended style.
-   `flutter pub run build_runner build`: Generates code for Freezed models and mocks.

### Release Scripts

Build versioned APKs for production:

-   `.\scripts\build_release.ps1 -BumpType patch`: Build release APK with version bump (PowerShell - **Recommended**)
-   `scripts\build_release.bat`: Build release APK (Windows Batch)
-   `./scripts/build_release.sh`: Build release APK (Linux/Mac)
-   `dart scripts/bump_version.dart [patch|minor|major]`: Manually increment version

📖 **For complete release instructions, see [RELEASE_GUIDE.md](RELEASE_GUIDE.md)**

## API Documentation

### Genre API

The Genre API provides access to the list of available book genres. For detailed documentation, see [Genre API Documentation](lib/services/README_GENRE_API.md).

**Quick Example:**

```dart
// Fetch all genres
final genreService = GenreService(supabase);
final genres = await genreService.listGenres();

// Use in a form
GenreSelector(
  genreService: genreService,
  selectedGenreId: selectedGenreId,
  onChanged: (genreId) => setState(() => selectedGenreId = genreId),
)
```

**Features:**
- ✅ 24-hour in-memory caching
- ✅ Comprehensive error handling
- ✅ Ready-to-use `GenreSelector` widget
- ✅ Automatic retry on network errors

**Available Genres (MVP):**
Biografia, Fantastyka, Horror, Kryminał, Literatura faktu, Literatura piękna, Poradnik, Przygodowa, Romans, Thriller, Inne

## Project Scope

### In Scope (MVP)

-   Full user authentication flow.
-   Complete library management features (add, edit, delete).
-   Integration with Google Books API for book data retrieval.
-   Reading session tracking (start, stop, log pages).
-   Filtering and sorting the book list.
-   Session history for each book.
-   Onboarding tutorial for new users.
-   Push notifications for active sessions.

### Out of Scope (Post-MVP)

-   Social features (friend lists, sharing progress).
-   Wishlist functionality.
-   Advanced statistics and data visualization.
-   AI-powered book recommendations.
-   Support for iOS or Web platforms.

## Project Status

This project is currently **in development**. The core features for the Minimum Viable Product (MVP) are being actively worked on.

## License

This project does not currently have a license.
