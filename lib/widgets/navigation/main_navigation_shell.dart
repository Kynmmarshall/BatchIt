import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/screens/batch/create_batch_screen.dart';
import 'package:batchit/screens/home/home_screen.dart';
import 'package:batchit/screens/orders/my_orders_screen.dart';
import 'package:batchit/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final screens = [
      const HomeScreen(),
      const CreateBatchScreen(),
      const MyOrdersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: l10n.home),
          NavigationDestination(
            icon: const Icon(Icons.add_circle_outline),
            label: l10n.createBatch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_bag_outlined),
            label: l10n.myOrders,
          ),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: l10n.profile),
        ],
      ),
    );
  }
}
