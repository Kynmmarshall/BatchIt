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

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => BatchProvider(BatchService())),
        ChangeNotifierProvider(create: (_) => OrderProvider(OrderService())),
      ],
      child: const BatchItApp(),
    ),
  );
}
