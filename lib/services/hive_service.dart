/// ============================================================================
/// [HiveService] - Centralized Hive persistence layer
/// ============================================================================
/// Manages all local data persistence using Hive NoSQL database.
/// Provides high-level CRUD operations for app settings, user profiles,
/// orders, and batches.
///
/// Responsibilities:
/// - Initialize Hive and register custom type adapters on app startup
/// - Manage Hive box lifecycle (open, close, clear)
/// - Provide clean API for CRU operations on persisted entities
/// - Handle Hive exceptions gracefully with logging
///
/// Boxes:
/// - 'app_settings': Stores theme mode and locale preferences
/// - 'user_profile': Stores authenticated user profile for session restore
/// - 'orders': Cached order data (id -> HiveOrder)
/// - 'batches': Cached batch data (id -> HiveBatch)
/// ============================================================================
library;

import 'package:batchit/models/hive_batch.dart';
import 'package:batchit/models/hive_order.dart';
import 'package:batchit/models/hive_user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  // Box names as constants
  static const String appSettingsBoxName = 'app_settings';
  static const String userProfileBoxName = 'user_profile';
  static const String ordersBoxName = 'orders';
  static const String batchesBoxName = 'batches';

  // Box references
  late Box<Map> _appSettingsBox;
  late Box<HiveUserProfile> _userProfileBox;
  late Box<HiveOrder> _ordersBox;
  late Box<HiveBatch> _batchesBox;

  // Getters for box access
  Box<Map> get appSettingsBox => _appSettingsBox;
  Box<HiveUserProfile> get userProfileBox => _userProfileBox;
  Box<HiveOrder> get ordersBox => _ordersBox;
  Box<HiveBatch> get batchesBox => _batchesBox;

  /// Initializes Hive and opens all required boxes.
  /// Must be called in main() before running the app.
  ///
  /// Sequence:
  /// 1. Initialize Hive Flutter (sets up platform-specific paths)
  /// 2. Register custom type adapters for Hive serialization
  /// 3. Open all persistence boxes
  /// 4. Log initialization status
  ///
  /// Returns: Completes when all boxes are ready
  Future<void> initialize() async {
    try {
      debugPrint('[HiveService] Initializing Hive...');

      // Initialize Hive Flutter
      await Hive.initFlutter();

      // Register custom type adapters
      Hive.registerAdapter(HiveUserProfileAdapter());
      Hive.registerAdapter(HiveBatchAdapter());
      Hive.registerAdapter(HiveOrderAdapter());
      Hive.registerAdapter(OrderStatusHiveAdapter());

      // Open all boxes
      _appSettingsBox = await Hive.openBox<Map>(appSettingsBoxName);
      _userProfileBox = await Hive.openBox<HiveUserProfile>(userProfileBoxName);
      _ordersBox = await Hive.openBox<HiveOrder>(ordersBoxName);
      _batchesBox = await Hive.openBox<HiveBatch>(batchesBoxName);

      debugPrint('[HiveService] Hive initialization complete');
      debugPrint(
        '[HiveService] Boxes: '
        'appSettings=${_appSettingsBox.length}, '
        'userProfile=${_userProfileBox.length}, '
        'orders=${_ordersBox.length}, '
        'batches=${_batchesBox.length}',
      );
    } catch (e) {
      debugPrint('[HiveService] Error during initialization: $e');
      rethrow;
    }
  }

  // ========== APP SETTINGS ==========

  /// Saves a single app setting (theme mode, locale, etc).
  /// Key can be: 'themeMode', 'locale', etc.
  Future<void> saveAppSetting(String key, dynamic value) async {
    try {
      await _appSettingsBox.put(key, {'value': value});
      debugPrint('[HiveService] Saved setting: $key = $value');
    } catch (e) {
      debugPrint('[HiveService] Error saving setting $key: $e');
      rethrow;
    }
  }

  /// Retrieves a single app setting, returns null if not found.
  dynamic getAppSetting(String key) {
    try {
      final data = _appSettingsBox.get(key);
      return data?['value'];
    } catch (e) {
      debugPrint('[HiveService] Error reading setting $key: $e');
      return null;
    }
  }

  /// Retrieves all app settings as a map.
  Map<String, dynamic> getAllAppSettings() {
    try {
      final result = <String, dynamic>{};
      for (final entry in _appSettingsBox.toMap().entries) {
        result[entry.key.toString()] = entry.value['value'];
      }
      return result;
    } catch (e) {
      debugPrint('[HiveService] Error reading all settings: $e');
      return {};
    }
  }

  /// Clears all app settings.
  Future<void> clearAppSettings() async {
    try {
      await _appSettingsBox.clear();
      debugPrint('[HiveService] Cleared app settings');
    } catch (e) {
      debugPrint('[HiveService] Error clearing settings: $e');
      rethrow;
    }
  }

  // ========== USER PROFILE ==========

  /// Saves the authenticated user profile.
  /// Only one profile can be stored at a time (key = 'current_user').
  Future<void> saveUserProfile(HiveUserProfile profile) async {
    try {
      await _userProfileBox.put('current_user', profile);
      debugPrint('[HiveService] Saved user profile: ${profile.email}');
    } catch (e) {
      debugPrint('[HiveService] Error saving user profile: $e');
      rethrow;
    }
  }

  /// Retrieves the current authenticated user profile, or null if not logged in.
  HiveUserProfile? getUserProfile() {
    try {
      return _userProfileBox.get('current_user');
    } catch (e) {
      debugPrint('[HiveService] Error reading user profile: $e');
      return null;
    }
  }

  /// Deletes the stored user profile (called on logout).
  Future<void> clearUserProfile() async {
    try {
      await _userProfileBox.delete('current_user');
      debugPrint('[HiveService] Cleared user profile');
    } catch (e) {
      debugPrint('[HiveService] Error clearing user profile: $e');
      rethrow;
    }
  }

  // ========== ORDERS ==========

  /// Saves or updates a single order.
  Future<void> saveOrder(HiveOrder order) async {
    try {
      await _ordersBox.put(order.id, order);
      debugPrint('[HiveService] Saved order: ${order.id}');
    } catch (e) {
      debugPrint('[HiveService] Error saving order ${order.id}: $e');
      rethrow;
    }
  }

  /// Saves multiple orders (bulk insert/update).
  Future<void> saveOrders(List<HiveOrder> orders) async {
    try {
      final orderMap = {for (var order in orders) order.id: order};
      await _ordersBox.putAll(orderMap);
      debugPrint('[HiveService] Saved ${orders.length} orders');
    } catch (e) {
      debugPrint('[HiveService] Error saving multiple orders: $e');
      rethrow;
    }
  }

  /// Retrieves a single order by ID.
  HiveOrder? getOrder(String orderId) {
    try {
      return _ordersBox.get(orderId);
    } catch (e) {
      debugPrint('[HiveService] Error reading order $orderId: $e');
      return null;
    }
  }

  /// Retrieves all cached orders.
  List<HiveOrder> getAllOrders() {
    try {
      return _ordersBox.values.toList();
    } catch (e) {
      debugPrint('[HiveService] Error reading all orders: $e');
      return [];
    }
  }

  /// Deletes a single order.
  Future<void> deleteOrder(String orderId) async {
    try {
      await _ordersBox.delete(orderId);
      debugPrint('[HiveService] Deleted order: $orderId');
    } catch (e) {
      debugPrint('[HiveService] Error deleting order $orderId: $e');
      rethrow;
    }
  }

  /// Clears all cached orders.
  Future<void> clearOrders() async {
    try {
      await _ordersBox.clear();
      debugPrint('[HiveService] Cleared all orders');
    } catch (e) {
      debugPrint('[HiveService] Error clearing orders: $e');
      rethrow;
    }
  }

  // ========== BATCHES ==========

  /// Saves or updates a single batch.
  Future<void> saveBatch(HiveBatch batch) async {
    try {
      await _batchesBox.put(batch.id, batch);
      debugPrint('[HiveService] Saved batch: ${batch.id}');
    } catch (e) {
      debugPrint('[HiveService] Error saving batch ${batch.id}: $e');
      rethrow;
    }
  }

  /// Saves multiple batches (bulk insert/update).
  Future<void> saveBatches(List<HiveBatch> batches) async {
    try {
      final batchMap = {for (var batch in batches) batch.id: batch};
      await _batchesBox.putAll(batchMap);
      debugPrint('[HiveService] Saved ${batches.length} batches');
    } catch (e) {
      debugPrint('[HiveService] Error saving multiple batches: $e');
      rethrow;
    }
  }

  /// Retrieves a single batch by ID.
  HiveBatch? getBatch(String batchId) {
    try {
      return _batchesBox.get(batchId);
    } catch (e) {
      debugPrint('[HiveService] Error reading batch $batchId: $e');
      return null;
    }
  }

  /// Retrieves all cached batches.
  List<HiveBatch> getAllBatches() {
    try {
      return _batchesBox.values.toList();
    } catch (e) {
      debugPrint('[HiveService] Error reading all batches: $e');
      return [];
    }
  }

  /// Deletes a single batch.
  Future<void> deleteBatch(String batchId) async {
    try {
      await _batchesBox.delete(batchId);
      debugPrint('[HiveService] Deleted batch: $batchId');
    } catch (e) {
      debugPrint('[HiveService] Error deleting batch $batchId: $e');
      rethrow;
    }
  }

  /// Clears all cached batches.
  Future<void> clearBatches() async {
    try {
      await _batchesBox.clear();
      debugPrint('[HiveService] Cleared all batches');
    } catch (e) {
      debugPrint('[HiveService] Error clearing batches: $e');
      rethrow;
    }
  }

  // ========== LIFECYCLE ==========

  /// Closes all Hive boxes and prepares for shutdown.
  /// Call during app cleanup or when reinitializing Hive.
  Future<void> close() async {
    try {
      await Hive.close();
      debugPrint('[HiveService] Hive closed');
    } catch (e) {
      debugPrint('[HiveService] Error closing Hive: $e');
      rethrow;
    }
  }

  /// Clears all data from all boxes (factory reset).
  /// Use with caution - typically only for logout or dev testing.
  Future<void> clearAll() async {
    try {
      await _appSettingsBox.clear();
      await _userProfileBox.clear();
      await _ordersBox.clear();
      await _batchesBox.clear();
      debugPrint('[HiveService] Cleared all data');
    } catch (e) {
      debugPrint('[HiveService] Error clearing all data: $e');
      rethrow;
    }
  }
}
