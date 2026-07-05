import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/models.dart';

// Icon/color/label for each transaction type and status, all in one place so
// the tiles, chips and anything else stay consistent.
abstract final class TransactionVisuals {
  const TransactionVisuals._();

  static IconData icon(TransactionType type) {
    switch (type) {
      case TransactionType.earn:
        return Icons.add_circle_outline;
      case TransactionType.redeem:
        return Icons.redeem_outlined;
      case TransactionType.transferIn:
        return Icons.south_west;
      case TransactionType.transferOut:
        return Icons.north_east;
      case TransactionType.purchase:
        return Icons.shopping_bag_outlined;
    }
  }

  static Color color(TransactionType type) {
    switch (type) {
      case TransactionType.earn:
        return AppColors.earn;
      case TransactionType.redeem:
        return AppColors.redeem;
      case TransactionType.transferIn:
        return AppColors.transferIn;
      case TransactionType.transferOut:
        return AppColors.transferOut;
      case TransactionType.purchase:
        return AppColors.purchase;
    }
  }

  static String typeLabel(AppLocalizations l10n, TransactionType type) {
    switch (type) {
      case TransactionType.earn:
        return l10n.filterEarn;
      case TransactionType.redeem:
        return l10n.filterRedeem;
      case TransactionType.transferIn:
      case TransactionType.transferOut:
        return l10n.filterTransfer;
      case TransactionType.purchase:
        return l10n.filterPurchase;
    }
  }

  static String statusLabel(AppLocalizations l10n, TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return l10n.statusCompleted;
      case TransactionStatus.pending:
        return l10n.statusPending;
      case TransactionStatus.failed:
        return l10n.statusFailed;
    }
  }

  static Color statusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.pending:
        return AppColors.pending;
      case TransactionStatus.failed:
        return AppColors.error;
    }
  }
}
