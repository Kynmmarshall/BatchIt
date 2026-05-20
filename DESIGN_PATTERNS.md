# Design Patterns in BatchIt

This document outlines the architectural and design patterns used throughout the BatchIt Flutter application.

---

## Table of Contents

1. [State Management Patterns](#state-management-patterns)
2. [Architectural Patterns](#architectural-patterns)
3. [Structural Patterns](#structural-patterns)
4. [Behavioral Patterns](#behavioral-patterns)
5. [UI/Widget Patterns](#uiwidget-patterns)
6. [Pattern Summary Table](#pattern-summary-table)

---

## State Management Patterns

### 1. **Provider Pattern (State Management)**

**Description:**  
Provider is a reactive state management solution that uses `ChangeNotifier` to notify listeners when state changes. It's a wrapper around `InheritedWidget` that simplifies state propagation through the widget tree.

**Use Case:**  
Managing global application state that needs to be accessible from multiple screens and widgets without passing state through constructor parameters (prop drilling).

**Implementation:**

- **File:** `lib/main.dart`
  ```dart
  void main() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
          ChangeNotifierProvider(create: (_) => OrderProvider(OrderService())),
          ChangeNotifierProvider(create: (_) => BatchProvider(BatchService())),
        ],
        child: const BatchItApp(),
      ),
    );
  }
  ```

- **Providers Used:**
  - **`AppSettingsProvider`** (`lib/providers/app_settings_provider.dart`): Manages theme mode (light/dark) and locale (EN/FR).
  - **`AuthProvider`** (`lib/providers/auth_provider.dart`): Manages user authentication state, login, logout, and user profile.
  - **`BatchProvider`** (`lib/providers/batch_provider.dart`): Manages batch listings and batch operations.
  - **`OrderProvider`** (`lib/providers/order_provider.dart`): Manages user orders and order lifecycle.

**Widget Access:**  
Widgets access providers using:
- `context.read<Provider>()` – One-time value retrieval
- `context.watch<Provider>()` – Reactive subscription (rebuilds on change)

**Example:**
```dart
// In app.dart - Consuming multiple providers
class BatchItApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettingsProvider>();
    final auth = context.watch<AuthProvider>();
    
    return MaterialApp(
      locale: appSettings.locale,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: appSettings.themeMode,
      home: auth.isAuthenticated ? const MainNavigationShell() : const SplashScreen(),
    );
  }
}
```

---

## Architectural Patterns

### 2. **Repository Pattern (Data Access Layer)**

**Description:**  
The Repository pattern abstracts data access logic, providing a single interface for data operations. Services act as repositories that encapsulate business logic and external API/database calls.

**Use Case:**  
Separating data access concerns from business logic. Services are called by providers to fetch or manipulate data.

**Implementation:**

- **Service Files:**
  - `lib/services/auth_service.dart` – Handles authentication API calls
  - `lib/services/batch_service.dart` – Handles batch listing and operations
  - `lib/services/order_service.dart` – Handles order data operations

- **Example** (`lib/services/auth_service.dart`):
  ```dart
  class AuthService {
    Future<UserProfile> loginWithEmail({
      required String email,
      required String password,
    }) async {
      // API call would happen here
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return UserProfile(
        id: 'u_01',
        name: 'BatchIt User',
        email: email,
      );
    }
  }
  ```

**Dependency Injection:**  
Services are injected into providers during initialization:
```dart
ChangeNotifierProvider(create: (_) => AuthProvider(AuthService()))
```

---

### 3. **MVVM (Model-View-ViewModel)**

**Description:**  
MVVM separates the UI (View) from business logic (ViewModel). The ViewModel exposes data and commands that the View observes and invokes.

**Use Case:**  
Organizing code so that UI widgets (Views) are decoupled from business logic (Providers acting as ViewModels).

**Implementation:**

- **Model Layer:** `lib/models/` (Batch, UserProfile, Order, etc.)
  - Contains immutable data models with computed properties.
  - Example: `lib/models/batch.dart`
    ```dart
    class Batch {
      final String id;
      final String productName;
      final double bulkSizeKg;
      final double currentQuantityKg;
      
      // Computed property
      double get progress =>
          bulkSizeKg == 0 ? 0 : (currentQuantityKg / bulkSizeKg).clamp(0, 1);
      
      bool get isFull => currentQuantityKg >= bulkSizeKg;
    }
    ```

- **ViewModel Layer:** `lib/providers/` (Providers act as ViewModels)
  - `AuthProvider` – Exposes `user`, `isAuthenticated`, `isLoading` and methods like `loginWithEmail()`, `logout()`
  - `BatchProvider` – Exposes batch list and filtering methods
  - `OrderProvider` – Exposes order list and management methods

- **View Layer:** `lib/screens/` (Stateless/Stateful Widgets)
  - `HomeScreen`, `ProfileScreen`, `NotificationsScreen`, etc.
  - These consume providers and react to state changes.

**Example Flow:**
```
User taps Login button (View)
  ↓
homeScreen calls authProvider.loginWithEmail() (ViewModel method)
  ↓
AuthProvider delegates to AuthService.loginWithEmail() (Repository)
  ↓
AuthProvider notifies listeners (ViewModel notifies View)
  ↓
View rebuilds with new auth state (View updates)
```

---

### 4. **Service Locator Pattern (Dependency Injection)**

**Description:**  
Services are instantiated once at app startup and injected into providers, ensuring a single instance throughout the app lifecycle.

**Use Case:**  
Providing dependencies to providers without tight coupling. Future: can replace with GetIt package for more sophisticated dependency management.

**Implementation:**

- **In `lib/main.dart`:**
  ```dart
  ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
  ChangeNotifierProvider(create: (_) => BatchProvider(BatchService())),
  ChangeNotifierProvider(create: (_) => OrderProvider(OrderService())),
  ```

- **Services are created once and passed to providers**, avoiding repeated instantiation.

---

## Structural Patterns

### 5. **Singleton Pattern (Implicit)**

**Description:**  
Providers are effectively singletons—they are created once via `ChangeNotifierProvider` and reused throughout the app lifecycle.

**Use Case:**  
Ensuring a single source of truth for application state (auth, batch data, orders, settings).

**Implementation:**

- All providers in `lib/providers/` are instantiated once in `MultiProvider` at app start.
- All widgets access the same provider instance via `context.watch()` or `context.read()`.

---

### 6. **Value Object / Data Class Pattern**

**Description:**  
Models are immutable, value-based objects that represent domain concepts. They use `const` constructors and override equality for comparison.

**Use Case:**  
Representing domain entities like Batch, Order, UserProfile in a type-safe, immutable way.

**Implementation:**

- **`lib/models/batch.dart`:**
  ```dart
  class Batch {
    const Batch({
      required this.id,
      required this.productName,
      required this.bulkSizeKg,
      required this.currentQuantityKg,
      required this.locationName,
      required this.hubName,
    });
    
    // Immutable fields
    final String id;
    final String productName;
    final double bulkSizeKg;
    final double currentQuantityKg;
    final String locationName;
    final String hubName;
  }
  ```

- **`lib/models/user_profile.dart`:**
  ```dart
  class UserProfile {
    const UserProfile({
      required this.id,
      required this.name,
      required this.email,
    });
    
    final String id;
    final String name;
    final String email;
  }
  ```

---

### 7. **Template Method Pattern (Theme System)**

**Description:**  
The Theme system defines a "template" for visual design (colors, spacing, shadows, typography) that is consistently applied across all screens.

**Use Case:**  
Ensuring visual consistency by centralizing design tokens and theme configuration.

**Implementation:**

- **`lib/themes/app_theme.dart`:**
  ```dart
  class AppTheme {
    static ThemeData light() => _build(Brightness.light);
    static ThemeData dark() => _build(Brightness.dark);
    
    static ThemeData _build(Brightness brightness) {
      final scheme = ColorScheme.fromSeed(seedColor: AppColors.seed);
      return ThemeData(
        colorScheme: scheme,
        textTheme: /* customized *,
        useMaterial3: true,
        // ... other theme properties
      );
    }
  }
  ```

- **Supporting Design Token Files:**
  - `lib/themes/app_colors.dart` – Color palette (primary, accent, surfaces, borders)
  - `lib/themes/app_spacing.dart` – Consistent spacing constants (16, 24, 32px, etc.)
  - `lib/themes/app_radius.dart` – Border radius values (8, 12, 16px, etc.)
  - `lib/themes/app_shadows.dart` – Shadow definitions
  - `lib/themes/app_motion.dart` – Animation constants
  - `lib/themes/app_icons.dart` – Icon size constants

**Applied in `app.dart`:**
```dart
return MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: appSettings.themeMode,
);
```

---

### 8. **Adapter Pattern (Localization)**

**Description:**  
Localization adapts the app's text and labels to different languages and locales. Flutter's `gen_l10n` system generates localization delegates and accessors.

**Use Case:**  
Supporting multiple languages (English, French) with string resources defined in ARB files.

**Implementation:**

- **ARB Files:** `lib/l10n/app_en.arb` (English), `lib/l10n/app_fr.arb` (French)
  ```json
  {
    "home": "Home",
    "createBatch": "Create Batch",
    "profile": "Profile",
    "notificationsScreenTitle": "Notifications",
    ...
  }
  ```

- **Generated Localization Class:** `lib/l10n/app_localizations.dart`
  - Flutter's build runner generates this from ARB files.
  - Provides type-safe access: `AppLocalizations.of(context)!.home`

- **Usage in Widgets:**
  ```dart
  final l10n = AppLocalizations.of(context)!;
  
  NavigationDestination(
    icon: Icons.home_outlined,
    label: l10n.home,  // Adapts to current locale
  )
  ```

---

## Behavioral Patterns

### 9. **Observer Pattern (Provider's ChangeNotifier)**

**Description:**  
`ChangeNotifier` is the backbone of the Observer pattern. Providers notify all listeners when state changes, causing widgets to rebuild reactively.

**Use Case:**  
Achieving reactive UI updates without manual widget management or callbacks.

**Implementation:**

- **Provider Extends ChangeNotifier:**
  ```dart
  class AuthProvider extends ChangeNotifier {
    UserProfile? _user;
    
    Future<void> loginWithEmail({...}) async {
      _isLoading = true;
      notifyListeners();  // Notify all observers (widgets)
      
      _user = await _authService.loginWithEmail(...);
      
      _isLoading = false;
      notifyListeners();  // Notify again
    }
  }
  ```

- **Widgets Subscribe via `context.watch()`:**
  ```dart
  final auth = context.watch<AuthProvider>();
  // Widget rebuilds whenever auth state changes
  ```

---

### 10. **Strategy Pattern (Authentication Methods)**

**Description:**  
Multiple authentication strategies (email/password, Google OAuth) are encapsulated in the same `AuthService` interface, allowing flexible implementation switching.

**Use Case:**  
Supporting multiple authentication methods without changing the Provider interface.

**Implementation:**

- **`lib/services/auth_service.dart`:**
  ```dart
  class AuthService {
    Future<UserProfile> loginWithEmail({...}) async { ... }
    Future<UserProfile> loginWithGoogle() async { ... }
  }
  ```

- **`lib/providers/auth_provider.dart`:**
  ```dart
  class AuthProvider extends ChangeNotifier {
    Future<void> loginWithEmail({...}) async {
      _user = await _authService.loginWithEmail(...);
      notifyListeners();
    }
    
    Future<void> loginWithGoogle() async {
      _user = await _authService.loginWithGoogle();
      notifyListeners();
    }
  }
  ```

- **Screens can call either strategy:**
  ```dart
  // LoginScreen can offer both options
  await authProvider.loginWithEmail(email, password);
  // OR
  await authProvider.loginWithGoogle();
  ```

---

### 11. **Command Pattern (Navigation Routes)**

**Description:**  
Named routes (`AppRoutes` constants) act as commands that specify which screen to display and any required arguments.

**Use Case:**  
Decoupling navigation logic from screen implementation. Enables deep linking, stack management, and route-based argument passing.

**Implementation:**

- **Route Constants:** `lib/core/app_routes.dart`
  ```dart
  class AppRoutes {
    static const String splashscreen = '/splash';
    static const String login = '/login';
    static const String shell = '/';
    static const String batchDetails = '/batch-details';
    static const String search = '/search';
    static const String notifications = '/notifications';
    ...
  }
  ```

- **Route Dispatcher:** `lib/app/app.dart`
  ```dart
  onGenerateRoute: (settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.batchDetails:
        final batchId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => BatchDetailsScreen(batchId: batchId));
      ...
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
  ```

- **Navigation Calls:**
  ```dart
  Navigator.pushNamed(context, AppRoutes.login);
  Navigator.pushNamed(context, AppRoutes.batchDetails, arguments: 'batch_123');
  ```

---

## UI/Widget Patterns

### 12. **Container Component Pattern**

**Description:**  
A reusable container component (`AppScreenContainer`) provides consistent layout, styling, and spacing for screens.

**Use Case:**  
Reducing boilerplate and ensuring visual consistency across all screens.

**Implementation:**

- **`lib/widgets/app_screen_container.dart`:**
  ```dart
  class AppScreenContainer extends StatelessWidget {
    final Widget child;
    
    @override
    Widget build(BuildContext context) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: /* background gradient */
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: child,
          ),
        ),
      );
    }
  }
  ```

- **Used in Every Screen:**
  ```dart
  class HomeScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return AppScreenContainer(
        child: Column(children: [/* screen content */]),
      );
    }
  }
  ```

---

### 13. **Compound Component / Card-Based UI Pattern**

**Description:**  
Complex UI is built by composing smaller card and tile components. Each component is self-contained and reusable.

**Use Case:**  
Breaking down complex screens into manageable, reusable pieces.

**Implementation:**

- **Examples:**
  - `NotificationTile` in `NotificationsScreen` – Displays individual notifications
  - `_MetricCard` in `ProfileScreen` – Shows user stats
  - Provider cards in `ProviderDiscoveryScreen` – Displays provider information
  - Batch cards in `HomeScreen` – Shows available batches

- **Example Component:**
  ```dart
  class _MetricCard extends StatelessWidget {
    final String label;
    final String value;
    
    @override
    Widget build(BuildContext context) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              SizedBox(height: AppSpacing.sm),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      );
    }
  }
  ```

---

### 14. **Tab Navigation / IndexedStack Pattern**

**Description:**  
The main app uses tab-based navigation with `IndexedStack` to efficiently switch between screens without destroying/recreating widget state.

**Use Case:**  
Maintaining tab state (scroll position, form inputs) when switching between tabs.

**Implementation:**

- **`lib/widgets/main_navigation_shell.dart`:**
  ```dart
  class _MainNavigationShellState extends State<MainNavigationShell> {
    int _index = 0;
    
    @override
    Widget build(BuildContext context) {
      final screens = [
        const HomeScreen(),
        const CreateBatchScreen(),
        const NotificationsScreen(),
        const ProfileScreen(),
        const MoreScreen(),
      ];
      
      return Scaffold(
        body: IndexedStack(
          index: _index,
          children: screens,  // All screens built at once; only selected renders
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) {
            setState(() => _index = value);
          },
          destinations: [ /* 5 nav items */ ],
        ),
      );
    }
  }
  ```

---

### 15. **Layout Composition Pattern (Wrap & Reflow)**

**Description:**  
The `Wrap` widget is used to create flexible, responsive layouts that reflow content when space is constrained.

**Use Case:**  
Displaying lists of tags, chips, or items that need to wrap gracefully to the next line.

**Implementation:**

- **NotificationsScreen:**
  ```dart
  Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.xs,
    children: [
      for (final action in actions)
        ActionChip(label: Text(action)),
    ],
  )
  ```

- **ProviderDiscoveryScreen – Category FilterChips:**
  ```dart
  Wrap(
    spacing: AppSpacing.md,
    children: categories.map((cat) => FilterChip(
      label: Text(cat),
      onSelected: (selected) { /* filter */ },
    )).toList(),
  )
  ```

---

## Pattern Summary Table

| Pattern | Type | Location(s) | Purpose |
|---------|------|-----------|---------|
| **Provider** | State Management | `lib/main.dart`, `lib/providers/*` | Reactive state across app |
| **Repository** | Data Access | `lib/services/*` | Encapsulate API/DB calls |
| **MVVM** | Architecture | `lib/models/*`, `lib/providers/*`, `lib/screens/*` | Separate UI from logic |
| **Service Locator** | Dependency Injection | `lib/main.dart` | Pass dependencies to providers |
| **Singleton** | Structural | `lib/providers/*` | Single instance per provider |
| **Value Object** | Data Structure | `lib/models/*` | Immutable, type-safe data |
| **Template Method** | Structural | `lib/themes/app_theme.dart` | Centralized design tokens |
| **Adapter** | Localization | `lib/l10n/*` | Multi-language support |
| **Observer** | Behavioral | `ChangeNotifier`, `context.watch()` | Reactive widget updates |
| **Strategy** | Behavioral | `lib/services/auth_service.dart` | Multiple auth methods |
| **Command** | Behavioral | `lib/core/app_routes.dart`, `app.dart` | Named route navigation |
| **Container Component** | UI | `lib/widgets/app_screen_container.dart` | Consistent screen layout |
| **Compound Component** | UI | `lib/screens/*` (tiles, cards) | Reusable UI pieces |
| **IndexedStack** | Navigation | `lib/widgets/main_navigation_shell.dart` | Tab-based screen switching |
| **Wrap Layout** | UI Layout | `lib/screens/notifications/*`, `lib/screens/providers/*` | Responsive content reflow |

---

## Conclusion

The BatchIt project uses a **layered, reactive architecture** built on Flutter's Provider pattern. The architecture emphasizes:

- **Separation of Concerns:** Models (data), Services (business logic), Providers (state), Views (UI)
- **Reactivity:** State changes automatically propagate to UI via `ChangeNotifier` and `context.watch()`
- **Consistency:** Design tokens and theme system ensure visual uniformity
- **Reusability:** Components, services, and providers are composable and testable
- **Localization:** Multi-language support via ARB files and localization adapters
- **Navigation:** Type-safe, command-based route management

This architecture scales well for medium-to-large Flutter applications and provides a solid foundation for future features like provider-based caching, real-time data sync, and advanced state management needs.
