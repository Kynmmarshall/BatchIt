/// ============================================================================
/// [BatchIt Application Entry Point]
/// ============================================================================
/// Initializes the Flutter application with Hive persistence and Provider state.
/// Sets up five core providers:
///   - HiveService: Manages all local data persistence (singleton)
///   - AppSettingsProvider: Manages theme/locale with persistence
///   - AuthProvider: Handles auth state with session restoration
///   - OrderProvider: Manages user orders and their lifecycle
///   - BatchProvider: Manages batch listings and batch-related operations
///
/// The MultiProvider wraps all providers in a single hierarchy so any widget
/// in the app tree can access state via context.read() or context.watch().
/// ============================================================================
library;

import 'package:batchit/app/app.dart';
import 'package:batchit/providers/app_settings_provider.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/providers/batch_provider.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/services/auth_service.dart';
import 'package:batchit/services/batch_service.dart';
import 'package:batchit/services/hive_service.dart';
import 'package:batchit/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Application entry point - initializes Hive, Provider state, and runs app.
///
/// Execution flow:
/// 1. Initialize Hive database and register type adapters
/// 2. Create HiveService singleton for persistence
/// 3. Set up MultiProvider with 5 root-level providers
/// 4. Pass HiveService to AppSettingsProvider and AuthProvider
/// 5. Run BatchItApp widget which handles routing based on auth state
///
/// Error handling:
/// - Hive initialization errors are rethrown to prevent app startup
/// - Subsequent provider errors are handled gracefully by each provider
void main() async {
  debugPrint('[BatchIt][main] App starting...');

  // Initialize Hive persistence layer
  final hiveService = HiveService();
  try {
    await hiveService.initialize();
    debugPrint('[BatchIt][main] Hive initialized successfully');
  } catch (e) {
    debugPrint('[BatchIt][main] FATAL: Failed to initialize Hive: $e');
    rethrow;
  }

  runApp(
    MultiProvider(
      providers: [
        // Provide HiveService to all child providers
        Provider<HiveService>(create: (_) => hiveService),

        // AppSettings with persistence
        ChangeNotifierProvider(create: (_) => AppSettingsProvider(hiveService)),

        // Auth with session restoration
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService(), hiveService),
        ),

        // Orders
        ChangeNotifierProvider(create: (_) => OrderProvider(OrderService())),

        // Batches with access to Orders
        ChangeNotifierProvider(
          create: (context) =>
              BatchProvider(BatchService(), context.read<OrderProvider>()),
        ),
      ],
      child: const BatchItApp(),
    ),
  );
}
