import 'package:flutter/material.dart';

import '../../../../core/error/wallet_exception.dart';
import '../../../../l10n/app_localizations.dart';

// Full-screen error with a retry button.
class WalletErrorView extends StatelessWidget {
  const WalletErrorView({
    super.key,
    required this.code,
    required this.fallbackMessage,
    required this.onRetry,
  });

  final WalletErrorCode code;
  final String fallbackMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              messageFor(l10n, code, fallbackMessage),
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  // Turn an error code into a localized message for the user.
  static String messageFor(
    AppLocalizations l10n,
    WalletErrorCode code,
    String fallback,
  ) {
    switch (code) {
      case WalletErrorCode.network:
        return l10n.errorNetwork;
      case WalletErrorCode.insufficientBalance:
        return l10n.errorInsufficientBalance;
      case WalletErrorCode.recipientNotFound:
        return l10n.errorRecipientNotFound;
      case WalletErrorCode.unknown:
        return l10n.errorGeneric;
    }
  }
}
