import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/language_toggle_button.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/models.dart';
import '../widgets/wallet_error_view.dart';
import 'transfer_cubit.dart';

// Send points to someone else.
// Sensitive data: we don't log the amount/recipient, turn off autofill and
// suggestions on those fields, and clear + dispose the controllers on exit so
// nothing sticks around in memory.
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, required this.availableBalance});

  static const routePath = 'transfer';
  static const routeName = 'transfer';

  final int availableBalance;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  static const int _minPoints = 100;
  static const int _maxNoteLength = 150;

  bool _isFormValid = false;

  @override
  void dispose() {
    // Wipe the fields before we let them go.
    _recipientController.clear();
    _amountController.clear();
    _noteController.clear();
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _revalidate() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final request = TransferRequest(
      recipient: _recipientController.text.trim(),
      points: int.parse(_amountController.text.trim()),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    context.read<TransferCubit>().submit(request);
  }

  Future<void> _showSuccessDialog(
    AppLocalizations l10n,
    TransferResult result,
  ) async {
    final locale = Localizations.localeOf(context).languageCode;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(l10n.transferSuccessTitle),
        content: Text(
          l10n.transferSuccessMessage(
            Formatters.points(result.points, locale: locale),
            Formatters.points(result.newBalance, locale: locale),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.done),
          ),
        ],
      ),
    );

    // Back to the wallet once they close the dialog.
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transferPoints),
        actions: const [LanguageToggleButton()],
      ),
      body: SafeArea(
        child: BlocConsumer<TransferCubit, TransferState>(
          listener: (context, state) {
            switch (state) {
              case TransferSuccess(:final result):
                _showSuccessDialog(l10n, result);
              case TransferFailure(:final code, :final message):
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        WalletErrorView.messageFor(l10n, code, message),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
              case TransferInitial():
              case TransferSubmitting():
                break;
            }
          },
          builder: (context, state) {
            final isSubmitting = state is TransferSubmitting;

            return CenteredContent(
              maxWidth: 520,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: _revalidate,
                child: ListView(
                  children: [
                    _AvailableBanner(
                      text: l10n.availableBalance(
                        Formatters.points(widget.availableBalance,
                            locale: locale),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _recipientController,
                      // Sensitive field: keep keyboard/autofill from remembering it.
                      autofillHints: const [],
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.recipientLabel,
                        hintText: l10n.recipientHint,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return l10n.validationRecipientRequired;
                        if (!Validators.isValidRecipient(v)) {
                          return l10n.validationRecipientInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.amountLabel,
                        hintText: l10n.amountHint,
                        prefixIcon: const Icon(Icons.stars_outlined),
                        suffixText: l10n.pointsUnit,
                      ),
                      validator: (value) => _validateAmount(l10n, value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      maxLength: _maxNoteLength,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: l10n.noteLabel,
                        hintText: l10n.noteHint,
                        prefixIcon: const Icon(Icons.notes_outlined),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value != null && value.length > _maxNoteLength) {
                          return l10n.validationNoteMax(_maxNoteLength);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed:
                          _isFormValid && !isSubmitting ? _submit : null,
                      child: isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : Text(l10n.sendPoints),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _validateAmount(AppLocalizations l10n, String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.validationAmountRequired;
    final points = int.tryParse(v);
    if (points == null) return l10n.validationAmountInteger;
    if (points < _minPoints) return l10n.validationAmountMin(_minPoints);
    if (points > widget.availableBalance) {
      return l10n.validationAmountMax(widget.availableBalance);
    }
    return null;
  }
}

class _AvailableBanner extends StatelessWidget {
  const _AvailableBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              color: scheme.onSecondaryContainer),
          const SizedBox(width: 10),
          Text(
            text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.onSecondaryContainer,
                ),
          ),
        ],
      ),
    );
  }
}
