// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'محفظة شوب بلس';

  @override
  String get walletTitle => 'المحفظة';

  @override
  String get totalBalance => 'الرصيد الكلي';

  @override
  String get pointsUnit => 'نقطة';

  @override
  String get pending => 'معلّقة';

  @override
  String get expiring => 'تنتهي قريبًا';

  @override
  String expiresOn(String date) {
    return 'تنتهي في $date';
  }

  @override
  String lastUpdated(String date) {
    return 'آخر تحديث $date';
  }

  @override
  String get transactions => 'المعاملات';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterEarn => 'ربح';

  @override
  String get filterRedeem => 'استبدال';

  @override
  String get filterTransfer => 'تحويل';

  @override
  String get filterPurchase => 'شراء';

  @override
  String get statusCompleted => 'مكتملة';

  @override
  String get statusPending => 'معلّقة';

  @override
  String get statusFailed => 'فشلت';

  @override
  String get emptyTransactionsTitle => 'لا توجد معاملات';

  @override
  String get emptyTransactionsMessage =>
      'ستظهر المعاملات المطابقة لهذا الفلتر هنا.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get errorGeneric => 'حدث خطأ ما. برجاء المحاولة مرة أخرى.';

  @override
  String get errorNetwork =>
      'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وأعد المحاولة.';

  @override
  String get errorInsufficientBalance => 'رصيدك من النقاط غير كافٍ.';

  @override
  String get errorRecipientNotFound => 'لم يتم العثور على المستلم.';

  @override
  String get transfer => 'تحويل';

  @override
  String get transferPoints => 'تحويل النقاط';

  @override
  String get recipientLabel => 'المستلم';

  @override
  String get recipientHint => 'هاتف (+20...) أو بريد إلكتروني';

  @override
  String get amountLabel => 'عدد النقاط';

  @override
  String get amountHint => 'الحد الأدنى 100 نقطة';

  @override
  String get noteLabel => 'ملاحظة (اختياري)';

  @override
  String get noteHint => 'أضف رسالة قصيرة';

  @override
  String availableBalance(String points) {
    return 'المتاح: $points نقطة';
  }

  @override
  String get sendPoints => 'إرسال النقاط';

  @override
  String get validationRecipientRequired => 'المستلم مطلوب';

  @override
  String get validationRecipientInvalid =>
      'أدخل رقم هاتف مصري صحيح (+20...) أو بريدًا إلكترونيًا';

  @override
  String get validationAmountRequired => 'عدد النقاط مطلوب';

  @override
  String get validationAmountInteger => 'أدخل رقمًا صحيحًا';

  @override
  String validationAmountMin(int min) {
    return 'الحد الأدنى $min نقطة';
  }

  @override
  String validationAmountMax(int max) {
    return 'لديك $max نقطة فقط';
  }

  @override
  String validationNoteMax(int max) {
    return 'يجب ألا تتجاوز الملاحظة $max حرفًا';
  }

  @override
  String get transferSuccessTitle => 'تم التحويل بنجاح';

  @override
  String transferSuccessMessage(String points, String balance) {
    return 'أرسلت $points نقطة. الرصيد الجديد: $balance نقطة.';
  }

  @override
  String get done => 'تم';
}
