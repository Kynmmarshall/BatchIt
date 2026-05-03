import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/screens/batch/create_batch_screen.dart';
import 'package:batchit/screens/home/home_screen.dart';
import 'package:batchit/screens/more/more_screen.dart';
import 'package:batchit/screens/orders/my_batches_screen.dart';
import 'package:batchit/screens/profile/profile_screen.dart';
import 'package:batchit/themes/app_icons.dart';
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
      const MyBatchesScreen(),
      const ProfileScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) {
              setState(() {
                _index = value;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined, size: AppIcons.lg),
                selectedIcon: const Icon(Icons.home_rounded, size: AppIcons.lg),
                label: l10n.home,
              ),
              NavigationDestination(
                icon: const Icon(Icons.add_circle_outline, size: AppIcons.lg),
                selectedIcon: const Icon(Icons.add_circle_rounded, size: AppIcons.lg),
                label: l10n.createBatch,
              ),
              NavigationDestination(
                icon: const Icon(Icons.shopping_bag_outlined, size: AppIcons.lg),
                selectedIcon: const Icon(Icons.shopping_bag_rounded, size: AppIcons.lg),
                label: l10n.myOrders,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline, size: AppIcons.lg),
                selectedIcon: const Icon(Icons.person, size: AppIcons.lg),
                label: l10n.profile,
              ),
              NavigationDestination(
                icon: const Icon(Icons.grid_view_outlined, size: AppIcons.lg),
                selectedIcon: const Icon(Icons.grid_view_rounded, size: AppIcons.lg),
                label: l10n.more,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
