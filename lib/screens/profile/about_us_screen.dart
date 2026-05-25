// ============================================================================
// [AboutUsScreen] - Team & app information screen
// ============================================================================
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:batchit/widgets/app_staggered_fade.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Team data ───────────────────────────────────────────────────────────────

class _TeamMember {
  const _TeamMember({
    required this.name,
    required this.role,
    required this.bio,
    required this.asset,
    required this.gradientColors,
    required this.badge,
    required this.skills,
  });

  final String name;
  final String role;
  final String bio;
  final String asset;
  final List<Color> gradientColors;
  final String badge;
  final List<String> skills;
}

const _team = [
  _TeamMember(
    name: 'Kamdeu Yamdjeuson',
    role: 'DevOps & Flutter Dev',
    bio:
        'Keeps the whole system humming — building the deployment pipeline that gets every update to you automatically, and adding the localisation and polish that makes the app feel at home in Cameroon.',
    asset: 'assets/team/kamdeu.jpg',
    gradientColors: [Color(0xFFF06292), Color(0xFF00E5A0)],
    badge: '🚀',
    skills: ['DevOps', 'Flutter', 'Localisation', 'Deployment'],
  ),
  _TeamMember(
    name: 'Njume Leslie',
    role: 'Backend Lead · API & Core Engine',
    bio:
        'Architects the backbone of BatchIt — from the smart order logic that fires automatically when a batch fills up, to the database systems that keep everything running smoothly.',
    asset: 'assets/team/leslie.jpg',
    gradientColors: [Color(0xFF00C484), Color(0xFF3B8BF5)],
    badge: '⚡',
    skills: ['Backend', 'APIs', 'Databases', 'Order Logic'],
  ),
  _TeamMember(
    name: 'Atsimbong Joshua',
    role: 'Flutter Dev · UI & Maps',
    bio:
        'Crafts the experience you hold in your hands — designing every screen, animation, and interaction to feel natural and delightful, from the map view to the dark mode toggle.',
    asset: 'assets/team/joshua.png',
    gradientColors: [Color(0xFFFFB547), Color(0xFFF06292)],
    badge: '📱',
    skills: ['Flutter', 'UI Design', 'Maps', 'Dark Mode'],
  ),
  _TeamMember(
    name: 'Chijioke Emmanuel',
    role: 'Backend Dev · Realtime & Chat',
    bio:
        'Makes BatchIt feel alive in real time — the live progress bars, instant chat messages, and notifications that keep you connected to your community as batches fill up.',
    asset: 'assets/team/chijioke.png',
    gradientColors: [Color(0xFF3B8BF5), Color(0xFF8B5CF6)],
    badge: '💬',
    skills: ['Realtime', 'Chat', 'Notifications', 'WebSockets'],
  ),
  _TeamMember(
    name: 'Fru Chi',
    role: 'Flutter Dev · Core Features',
    bio:
        'Drives the core product experience — building the batch creation flow, order management, and the provider discovery system that connects communities with trusted local suppliers.',
    asset: 'assets/team/fru.png',
    gradientColors: [Color(0xFF0B8A62), Color(0xFFFFB347)],
    badge: '🛠️',
    skills: ['Flutter', 'State Management', 'Providers', 'Orders'],
  ),
];

// ── Screen ──────────────────────────────────────────────────────────────────

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: AppScreenContainer(
        child: ListView(
          children: [
            // ── App banner ─────────────────────────────────────────────────
            AppStaggeredFade(
              index: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary.withValues(alpha: 0.9),
                      scheme.secondary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/icon/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.shopping_bag_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'BatchIt',
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Buy Together, Save Together',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Built in Yaoundé, Cameroon 🇨🇲',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Mission quote ──────────────────────────────────────────────
            AppStaggeredFade(
              index: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.format_quote_rounded,
                              color: scheme.primary, size: 28),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Our Mission',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '"We built BatchIt because we saw our own families paying too much for everyday essentials. When you buy alone, you pay retail. When you buy together, everyone wins."',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '— The BatchIt Team',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Team section header ────────────────────────────────────────
            AppStaggeredFade(
              index: 2,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: AppSpacing.xs, bottom: AppSpacing.sm),
                child: Text(
                  'Meet the Team',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // ── Team cards ─────────────────────────────────────────────────
            ...List.generate(_team.length, (i) {
              final member = _team[i];
              return AppStaggeredFade(
                index: i + 3,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _TeamCard(member: member),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.lg),

            // ── App version / links ────────────────────────────────────────
            AppStaggeredFade(
              index: _team.length + 3,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Info',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _InfoRow(
                        icon: Icons.info_outline_rounded,
                        label: 'Version',
                        value: '1.0.0',
                      ),
                      _InfoRow(
                        icon: Icons.language_rounded,
                        label: 'Website',
                        value: 'batchit',
                        onTap: () => launchUrl(Uri.parse('https://batchit.duckdns.org')),
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Based in',
                        value: 'Yaoundé, Cameroon 🇨🇲',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ── Team card widget ─────────────────────────────────────────────────────────

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.member});

  final _TeamMember member;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + name row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: member.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: scheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          member.asset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              member.name.substring(0, 1),
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: scheme.outlineVariant, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            member.badge,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.role,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Bio
            Text(
              member.bio,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.55,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Skills
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: member.skills
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppSpacing.xl),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Text(
                        s,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: onTap != null ? scheme.primary : null,
                fontWeight: FontWeight.w600,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
