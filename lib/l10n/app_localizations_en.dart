// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ShopPlus Wallet';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get pointsUnit => 'pts';

  @override
  String get pending => 'Pending';

  @override
  String get expiring => 'Expiring';

  @override
  String expiresOn(String date) {
    return 'Expires on $date';
  }

  @override
  String lastUpdated(String date) {
    return 'Last updated $date';
  }

  @override
  String get transactions => 'Transactions';

  @override
  String get filterAll => 'All';

  @override
  String get filterEarn => 'Earn';

  @override
  String get filterRedeem => 'Redeem';

  @override
  String get filterTransfer => 'Transfer';

  @override
  String get filterPurchase => 'Purchase';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusFailed => 'Failed';

  @override
  String get emptyTransactionsTitle => 'No transactions yet';

  @override
  String get emptyTransactionsMessage =>
      'Transactions matching this filter will appear here.';

  @override
  String get retry => 'Retry';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'No internet connection. Check your network and retry.';

  @override
  String get errorInsufficientBalance => 'You don\'t have enough points.';

  @override
  String get errorRecipientNotFound => 'Recipient not found.';

  @override
  String get transfer => 'Transfer';

  @override
  String get transferPoints => 'Transfer Points';

  @override
  String get recipientLabel => 'Recipient';

  @override
  String get recipientHint => 'Phone (+20...) or email';

  @override
  String get amountLabel => 'Points amount';

  @override
  String get amountHint => 'Minimum 100 points';

  @override
  String get noteLabel => 'Note (optional)';

  @override
  String get noteHint => 'Add a short message';

  @override
  String availableBalance(String points) {
    return 'Available: $points pts';
  }

  @override
  String get sendPoints => 'Send Points';

  @override
  String get validationRecipientRequired => 'Recipient is required';

  @override
  String get validationRecipientInvalid =>
      'Enter a valid Egyptian phone (+20...) or email';

  @override
  String get validationAmountRequired => 'Amount is required';

  @override
  String get validationAmountInteger => 'Enter a whole number';

  @override
  String validationAmountMin(int min) {
    return 'Minimum is $min points';
  }

  @override
  String validationAmountMax(int max) {
    return 'You only have $max points';
  }

  @override
  String validationNoteMax(int max) {
    return 'Note must be $max characters or fewer';
  }

  @override
  String get transferSuccessTitle => 'Transfer successful';

  @override
  String transferSuccessMessage(String points, String balance) {
    return 'You sent $points pts. New balance: $balance pts.';
  }

  @override
  String get done => 'Done';
}
