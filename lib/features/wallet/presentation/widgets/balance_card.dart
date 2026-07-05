import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/models.dart';

/// The hero card showing the total balance plus pending/expiring points.
///
/// `const` where possible and self-contained so it only rebuilds when the
/// [balance] it is given actually changes.
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.balance});

  final PointsBalance balance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xFF8B7BF0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: '${l10n.totalBalance}: '
                  '${Formatters.points(balance.totalPoints, locale: locale)} '
                  '${l10n.pointsUnit}',
              child: ExcludeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      Formatters.points(balance.totalPoints, locale: locale),
                      style: textTheme.displaySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        l10n.pointsUnit,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.totalBalance,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: l10n.pending,
                    value: Formatters.points(
                      balance.pendingPoints,
                      locale: locale,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: AppColors.white.withValues(alpha: 0.25),
                ),
                Expanded(
                  child: _MiniStat(
                    label: l10n.expiring,
                    value: Formatters.points(
                      balance.expiringPoints,
                      locale: locale,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}
