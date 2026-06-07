//============================================================================
//[MainNavigationShell] - Root-level tab navigator for authenticated users
//============================================================================
//StatefulWidget that manages bottom navigation bar (5 tabs) and IndexedStack
//for tab-based screen switching after user authentication.
//
//Tab structure (in order, index 0-4):
//0. Home - Browse nearby batches and active batch carousel
//1. Create Batch - Form to create new bulk purchasing batch
//2. Notifications - Alert feed grouped by date
//3. Profile - User account dashboard and settings
//4. More - Additional features (Map, Chat, Provider Discovery)
//
//State management:
//- Local _index tracks selected tab (0-4)
//- IndexedStack houses all 5 screens (only selected renders)
//- setState on tab selection to update _index
//- All screens persist state while not visible
//
//Key responsibilities:
//- Render bottom NavigationBar with localized labels
//- Switch between tab screens via IndexedStack
//- Maintain visual selection state (icon/label highlighting)
//- Apply platform-consistent bottom safe area
//============================================================================
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/providers/notification_provider.dart';
import 'package:batchit/screens/batch/create_batch_screen.dart';
import 'package:batchit/screens/home/home_screen.dart';
import 'package:batchit/screens/more/more_screen.dart';
import 'package:batchit/screens/notifications/notifications_screen.dart';
import 'package:batchit/screens/profile/profile_screen.dart';
import 'package:batchit/themes/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

//Holds mutable tab state and renders bottom navigation UI.
//Updates _index on destination selection to trigger rebuild.
class _MainNavigationShellState extends State<MainNavigationShell> {
  int _index = 0;

  // Screens are built lazily — only when first visited. Once built, the
  // same widget instance is returned on every subsequent rebuild so Flutter
  // reuses the element and preserves the screen's State.
  final _screenCache = <int, Widget>{};

  Widget _screenFor(int i) => _screenCache.putIfAbsent(
        i,
        () => switch (i) {
          0 => const HomeScreen(),
          1 => const CreateBatchScreen(),
          2 => const NotificationsScreen(),
          3 => const ProfileScreen(),
          4 => const MoreScreen(),
          _ => throw StateError('Unknown tab $i'),
        },
      );

  @override
  void initState() {
    super.initState();
    _screenFor(0); // Build Home immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    final hasUnread = unreadCount > 0;

    // Build children list: cached widget for visited tabs, zero-cost
    // SizedBox.shrink() placeholder for tabs the user hasn't opened yet.
    // The currently active tab is always created/returned from cache.
    final children = List<Widget>.generate(
      5,
      (i) => _screenCache.containsKey(i)
          ? _screenCache[i]!
          : const SizedBox.shrink(),
    );
    children[_index] = _screenFor(_index);

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: children,
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
            onDestinationSelected: (i) {
              setState(() => _index = i);
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
                icon: _NotifIcon(hasUnread: hasUnread, selected: false),
                selectedIcon: _NotifIcon(hasUnread: hasUnread, selected: true),
                label: l10n.notificationsScreenTitle,
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

//Bell icon that turns green and shows a badge dot when there are unread notifications.
class _NotifIcon extends StatelessWidget {
  const _NotifIcon({required this.hasUnread, required this.selected});

  final bool hasUnread;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = hasUnread ? Colors.green : null;
    final icon = Icon(
      selected ? Icons.notifications_rounded : Icons.notifications_none_rounded,
      size: AppIcons.lg,
      color: color,
    );

    if (!hasUnread) return icon;

    return Badge(
      backgroundColor: Colors.green,
      smallSize: 8,
      child: icon,
    );
  }
}
