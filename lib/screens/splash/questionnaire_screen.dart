import 'package:batchit/core/app_routes.dart';
import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/widgets/auth/auth_screen_shell.dart';
import 'package:flutter/material.dart';

const _fieldBackground = Color(0xFFF1F1F1);

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final Set<String> _selectedCategories = {'groceries'};
  String _shoppingFrequency = 'weekly';
  String _preferredRegion = 'nearby';
  String _budgetRange = 'flexible';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const primaryText = Color(0xFF1E2B46);
    const secondaryText = Color(0xFF91A0B2);
    const primaryButton = Color(0xFF1A2745);

    return AuthScreenShell(
      childBuilder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                color: primaryText,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.questionnaireTitle,
              style: const TextStyle(
                color: primaryText,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.questionnaireSubtitle,
              style: const TextStyle(
                color: secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 26),
            _QuestionBlock(
              title: l10n.productCategories,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SelectChip(
                    label: l10n.questionnaireChipGroceries,
                    selected: _selectedCategories.contains('groceries'),
                    onTap: () => _toggleCategory('groceries'),
                  ),
                  _SelectChip(
                    label: l10n.questionnaireChipHousehold,
                    selected: _selectedCategories.contains('household'),
                    onTap: () => _toggleCategory('household'),
                  ),
                  _SelectChip(
                    label: l10n.questionnaireChipSnacks,
                    selected: _selectedCategories.contains('snacks'),
                    onTap: () => _toggleCategory('snacks'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _QuestionBlock(
              title: l10n.shoppingFrequency,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SelectChip(
                    label: l10n.questionnaireChipWeekly,
                    selected: _shoppingFrequency == 'weekly',
                    onTap: () => setState(() => _shoppingFrequency = 'weekly'),
                  ),
                  _SelectChip(
                    label: l10n.questionnaireChipBiweekly,
                    selected: _shoppingFrequency == 'biweekly',
                    onTap: () => setState(() => _shoppingFrequency = 'biweekly'),
                  ),
                  _SelectChip(
                    label: l10n.questionnaireChipMonthly,
                    selected: _shoppingFrequency == 'monthly',
                    onTap: () => setState(() => _shoppingFrequency = 'monthly'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _QuestionBlock(
              title: l10n.preferredRegions,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SelectChip(
                    label: l10n.questionnaireChipNearby,
                    selected: _preferredRegion == 'nearby',
                    onTap: () => setState(() => _preferredRegion = 'nearby'),
                  ),
                  _SelectChip(
                    label: l10n.questionnaireChipCitywide,
                    selected: _preferredRegion == 'citywide',
                    onTap: () => setState(() => _preferredRegion = 'citywide'),
                  ),
                  _SelectChip(
                    label: l10n.questionnaireChipFlexible,
                    selected: _preferredRegion == 'flexible',
                    onTap: () => setState(() => _preferredRegion = 'flexible'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _QuestionBlock(
              title: l10n.budgetRange,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SelectChip(
                    label: 'Under 20',
                    selected: _budgetRange == 'low',
                    onTap: () => setState(() => _budgetRange = 'low'),
                  ),
                  _SelectChip(
                    label: '20 - 50',
                    selected: _budgetRange == 'medium',
                    onTap: () => setState(() => _budgetRange = 'medium'),
                  ),
                  _SelectChip(
                    label: '50+',
                    selected: _budgetRange == 'flexible',
                    onTap: () => setState(() => _budgetRange = 'flexible'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: primaryButton,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                ),
                child: Text(
                  l10n.questionnaireContinue,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                style: TextButton.styleFrom(
                  foregroundColor: secondaryText,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(l10n.questionnaireSkip),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleCategory(String value) {
    setState(() {
      if (_selectedCategories.contains(value)) {
        _selectedCategories.remove(value);
      } else {
        _selectedCategories.add(value);
      }
    });
  }
}

class _QuestionBlock extends StatelessWidget {
  const _QuestionBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1E2B46),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF1E2B46),
        fontWeight: FontWeight.w600,
      ),
      selectedColor: const Color(0xFF1A2745),
      backgroundColor: _fieldBackground,
      side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }
}
