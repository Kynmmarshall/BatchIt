import 'dart:io';

import 'package:batchit/models/hive_user_profile.dart';
import 'package:batchit/models/hive_batch.dart';
import 'package:batchit/models/hive_order.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late String tempPath;

  setUpAll(() async {
    tempPath = Directory.systemTemp.createTempSync('batchit_hive_test').path;
    Hive.init(tempPath);

    Hive.registerAdapter(HiveUserProfileAdapter());
    Hive.registerAdapter(HiveBatchAdapter());
    Hive.registerAdapter(OrderStatusHiveAdapter());
    Hive.registerAdapter(HiveOrderAdapter());

    await Hive.openBox<Map>('app_settings');
    await Hive.openBox<HiveUserProfile>('user_profile');
    await Hive.openBox<HiveOrder>('orders');
    await Hive.openBox<HiveBatch>('batches');
  });

  tearDownAll(() async {
    if (Hive.isBoxOpen('app_settings')) {
      await Hive.box<Map>('app_settings').clear();
      await Hive.box<Map>('app_settings').close();
    }
    if (Hive.isBoxOpen('user_profile')) {
      await Hive.box<HiveUserProfile>('user_profile').clear();
      await Hive.box<HiveUserProfile>('user_profile').close();
    }
    if (Hive.isBoxOpen('orders')) {
      await Hive.box<HiveOrder>('orders').clear();
      await Hive.box<HiveOrder>('orders').close();
    }
    if (Hive.isBoxOpen('batches')) {
      await Hive.box<HiveBatch>('batches').clear();
      await Hive.box<HiveBatch>('batches').close();
    }
    await Hive.close();
    try {
      Directory(tempPath).deleteSync(recursive: true);
    } catch (_) {}
  });

  test('save and read app setting', () async {
    final settingsBox = Hive.box<Map>('app_settings');
    await settingsBox.put('unit_test_key', {'value': 'unit_value'});
    final v = settingsBox.get('unit_test_key')?['value'];
    expect(v, 'unit_value');
  });

  test('save and restore user profile', () async {
    final profile = HiveUserProfile()
      ..id = 't_user'
      ..name = 'Test User'
      ..email = 'test@example.com'
      ..avatarUrl = null;

    final userBox = Hive.box<HiveUserProfile>('user_profile');
    await userBox.put('current_user', profile);

    final loaded = userBox.get('current_user');
    expect(loaded, isNotNull);
    expect(loaded!.email, 'test@example.com');
    expect(loaded.name, 'Test User');
  });
}
