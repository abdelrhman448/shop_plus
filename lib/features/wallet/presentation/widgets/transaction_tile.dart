import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/models.dart';
import 'transaction_visuals.dart';

// One row: icon/logo, description, time, points and status. CachedNetworkImage
// keeps logos cached so we don't refetch them while scrolling.
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final textTheme = Theme.of(context).textTheme;
    final color = TransactionVisuals.color(transaction.type);

    return Semantics(
      label: '${transaction.description}, '
          '${Formatters.signedPoints(transaction.points, locale: locale)} '
          '${l10n.pointsUnit}, '
          '${TransactionVisuals.statusLabel(l10n, transaction.status)}',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              _Leading(transaction: transaction, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.dateTime(transaction.createdAt, locale: locale),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.signedPoints(transaction.points, locale: locale),
                    style: textTheme.titleSmall?.copyWith(
                      color: transaction.isCredit
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _StatusChip(status: transaction.status, l10n: l10n),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.transaction, required this.color});

  final Transaction transaction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final logo = transaction.merchantLogo;
    final icon = Icon(TransactionVisuals.icon(transaction.type), color: color);

    if (logo == null || logo.isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: color.withValues(alpha: 0.12),
        child: icon,
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: color.withValues(alpha: 0.12),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: logo,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (_, _) => icon,
          errorWidget: (_, _, _) => icon,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l10n});

  final TransactionStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = TransactionVisuals.statusColor(status);
    return Text(
      TransactionVisuals.statusLabel(l10n, status),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
    );
  }
}
