# BatchIt

BatchIt is a Flutter application for collective bulk buying. It helps nearby users join product batches, reach target quantities, and collect orders through local hubs.

## Overview

Instead of buying full wholesale quantities alone, users can collaborate in shared batches. This reduces cost per user and improves access to bulk pricing.

Core flow:
- Discover nearby/open/full batches
- Join a batch and track progress
- Complete order collection through hubs
- Manage account preferences (language/theme)

## Features

- Authentication screens: splash, onboarding, login, register, verification
- Batch browsing and filtering (nearby/open/full)
- Batch details and join flow
- Main navigation shell for core app sections
- Localization support (English and French)
- Theme support (light and dark)
- Provider-based state management
- Route generation with transitions and safe fallback route

## Tech Stack

- Flutter (Material)
- Dart SDK ^3.9.2
- Provider for state management
- intl + Flutter gen-l10n for localization
- flutter_localizations for i18n delegates

## Project Structure

High-level layout:

```text
lib/
	app/          # App bootstrapping and route generation
	core/         # Constants, routes, shared utilities
	l10n/         # ARB files and generated localization files
	models/       # Domain models
	providers/    # App/Auth/Batch/Order state providers
	screens/      # UI screens by feature
	services/     # Business/data service layer
	theme/        # Theme resources
	themes/       # Color/motion/spacing/theme config
	widgets/      # Reusable widgets (cards, shells, navigation)
assets/
	background/
	batches/
	icon/
	onboaring/
```

## Routing

Defined in `lib/core/app_routes.dart` and generated in `lib/app/app.dart`.

Main routes:
- `/splash`
- `/onboarding`
- `/login`
- `/register`
- `/verification-code`
- `/` (main shell)
- `/batch-details`
- `/join-batch`

## State Management

Providers are registered in `lib/main.dart`:
- `AppSettingsProvider`
- `AuthProvider`
- `BatchProvider`
- `OrderProvider`

These providers consume services from `lib/services/`.

## Localization

Localization is configured with `l10n.yaml` and ARB files in `lib/l10n/`.

Supported locales:
- English (`en`)
- French (`fr`)

Key files:
- `lib/l10n/app_en.arb`
- `lib/l10n/app_fr.arb`
- `lib/l10n/app_localizations.dart` (generated)

Generate localization output:

```bash
flutter gen-l10n
```

## Theming

- Light and dark themes are provided by `AppTheme` in `lib/themes/app_theme.dart`.
- Locale and theme mode are controlled through `AppSettingsProvider`.

## Getting Started

### Prerequisites

- Flutter SDK installed
- A configured Flutter device target (Windows/Android/iOS/Web)

### Install and Run

```bash
flutter pub get
flutter gen-l10n
flutter run
```

### Run on Windows specifically

```bash
flutter config --enable-windows-desktop
flutter run -d windows
```

VS Code launch profile is available in `.vscode/launch.json`:
- `BatchIt (Flutter Windows)`

## Quality Checks

Run analyzer:

```bash
dart analyze
```

Run tests:

```bash
flutter test
```

## Assets

Declared in `pubspec.yaml`:
- `assets/icon/`
- `assets/background/`
- `assets/onboaring/`
- `assets/batches/`

## Notes

- This project currently uses `publish_to: 'none'` (not intended for publishing).
- Keep ARB keys synchronized across locales before generating localization files.
- Avoid using Dart reserved keywords as ARB key names.