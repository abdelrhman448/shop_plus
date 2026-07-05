import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/models.dart';

/// Horizontal row of filter chips for the transaction list.
///
/// A `null` [selected] value represents the "All" chip. The parent owns the
/// selection state; this widget is purely presentational.
class TransactionFilterBar extends StatelessWidget {
  const TransactionFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final TransactionType? selected;
  final ValueChanged<TransactionType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Grouped filters: "Transfer" covers both in and out for a simpler UX.
    final filters = <(_FilterKey, String)>[
      (const _FilterKey.all(), l10n.filterAll),
      (const _FilterKey.type(TransactionType.earn), l10n.filterEarn),
      (const _FilterKey.type(TransactionType.redeem), l10n.filterRedeem),
      (const _FilterKey.type(TransactionType.purchase), l10n.filterPurchase),
      (const _FilterKey.type(TransactionType.transferIn), l10n.filterTransfer),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (key, label) = filters[index];
          final isSelected = key.matches(selected);
          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelected(key.type),
          );
        },
      ),
    );
  }
}

/// Identifies a filter chip: either "All" (no type) or a specific type.
class _FilterKey {
  const _FilterKey.all() : type = null;
  const _FilterKey.type(this.type);

  final TransactionType? type;

  bool matches(TransactionType? selected) => selected == type;
}
