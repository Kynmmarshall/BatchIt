/// ============================================================================
/// [BatchIt Application Entry Point]
/// ============================================================================
/// Initializes the Flutter application with global Provider state management.
/// Sets up four core providers:
///   - AppSettingsProvider: Manages app theme, locale, and user preferences
///   - AuthProvider: Handles authentication state and user identity
///   - OrderProvider: Manages user orders and their lifecycle
///   - BatchProvider: Manages batch listings and batch-related operations
///
/// The MultiProvider wraps all providers in a single hierarchy so any widget
/// in the app tree can access state via context.read() or context.watch().
/// ============================================================================

import 'package:batchit/app/app.dart';
import 'package:batchit/providers/app_settings_provider.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/services/auth_service.dart';
import 'package:batchit/services/batch_service.dart';
import 'package:batchit/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Application entry point - initializes Provider state and runs the app.
/// 
/// Execution flow:
/// 1. Sets up MultiProvider with 4 root-level providers
/// 2. Passes AppSettings and Auth providers first for app initialization
/// 3. Passes Batch and Order providers with dependencies on other providers
/// 4. Runs BatchItApp widget which handles routing based on auth state
void main() {
  debugPrint('[BatchIt][main] App starting...');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => OrderProvider(OrderService())),
        ChangeNotifierProvider(
          create: (context) => BatchProvider(
            BatchService(),
            context.read<OrderProvider>(),
          ),
        ),
      ],
      child: const BatchItApp(),
    ),
  );
}
