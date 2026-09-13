// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تتبع المصروفات';

  @override
  String get historyTooltip => 'السجل';

  @override
  String get settingsTooltip => 'الإعدادات';

  @override
  String get addExpenseTooltip => 'إضافة مصروف';

  @override
  String get previousMonthTooltip => 'الشهر السابق';

  @override
  String get nextMonthTooltip => 'الشهر التالي';

  @override
  String get spentThisMonth => 'إنفاق هذا الشهر';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String categoryThisMonth(String category) {
    return '$category هذا الشهر';
  }

  @override
  String get noExpensesThisMonth =>
      'لا توجد مصروفات هذا الشهر.\nاضغط + لإضافة مصروف.';

  @override
  String noCategoryExpensesThisMonth(String category) {
    return 'لا توجد مصروفات ضمن «$category» هذا الشهر.';
  }

  @override
  String get noSpendingToChart => 'لا يوجد إنفاق لعرضه هذا الشهر.';

  @override
  String couldNotLoadTotals(Object error) {
    return 'تعذّر تحميل الإجماليات: $error';
  }

  @override
  String couldNotLoadExpenses(Object error) {
    return 'تعذّر تحميل المصروفات: $error';
  }

  @override
  String couldNotLoadHistory(Object error) {
    return 'تعذّر تحميل السجل: $error';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get historyTitle => 'السجل';

  @override
  String get groupByDay => 'يوم';

  @override
  String get groupByMonth => 'شهر';

  @override
  String get noExpensesYet =>
      'لا توجد مصروفات بعد.\nأضف مصروفًا من الشاشة الرئيسية.';

  @override
  String get expenseDeleted => 'تم حذف المصروف';

  @override
  String get undo => 'تراجع';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get removeAdsTitle => 'إزالة الإعلانات';

  @override
  String get removeAdsSubtitle =>
      'إخفاء الشريط الإعلاني على لوحة المعلومات في هذا الجهاز';

  @override
  String get currencyTitle => 'العملة';

  @override
  String get currencySubtitle => 'تظهر في الإجماليات والقوائم ونموذج المصروف';

  @override
  String get currencyEgyptianPound => 'جنيه مصري';

  @override
  String get currencyDollar => 'دولار';

  @override
  String get currencyEuro => 'يورو';

  @override
  String get currencyPound => 'جنيه إسترليني';

  @override
  String get currencyYen => 'ين';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageSubtitle =>
      'الإنجليزية أو العربية — تُطبَّق على التطبيق بالكامل';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get exportData => 'تصدير البيانات';

  @override
  String get exportDataSubtitle => 'مشاركة جميع المصروفات كملف CSV';

  @override
  String get importData => 'استيراد البيانات';

  @override
  String get importDataSubtitle => 'إضافة مصروفات من ملف CSV مُصدَّر';

  @override
  String exportFailed(Object error) {
    return 'فشل التصدير: $error';
  }

  @override
  String importFailed(Object error) {
    return 'فشل الاستيراد: $error';
  }

  @override
  String importResult(int inserted, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: 'تم استيراد $inserted وتخطي $skipped من العناصر المكررة.',
      one: 'تم استيراد $inserted وتخطي عنصر مكرر واحد.',
    );
    return '$_temp0';
  }

  @override
  String get exportShareSubject => 'تصدير تتبع المصروفات';

  @override
  String get addExpenseTitle => 'إضافة مصروف';

  @override
  String get editExpenseTitle => 'تعديل المصروف';

  @override
  String get amountLabel => 'المبلغ';

  @override
  String get amountHint => '0.00';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get customCategoryLabel => 'فئة مخصصة';

  @override
  String get customCategoryHint => 'مثال: نادي رياضي، هدايا…';

  @override
  String get enterCustomCategory => 'أدخل اسم الفئة';

  @override
  String get noteLabel => 'ملاحظة (اختياري)';

  @override
  String get save => 'حفظ';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get saving => 'جارٍ الحفظ…';

  @override
  String get enterAmount => 'أدخل مبلغًا';

  @override
  String get amountMustBePositive => 'يجب أن يكون المبلغ أكبر من صفر';

  @override
  String couldNotSaveExpense(Object error) {
    return 'تعذّر حفظ المصروف: $error';
  }

  @override
  String showAllTotal(String amount) {
    return 'عرض الكل · الإجمالي $amount';
  }

  @override
  String get categoryFood => 'طعام';

  @override
  String get categoryTransport => 'مواصلات';

  @override
  String get categoryBills => 'فواتير';

  @override
  String get categoryEntertainment => 'ترفيه';

  @override
  String get categoryShopping => 'تسوّق';

  @override
  String get categoryHealth => 'صحة';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get accountsTitle => 'الحسابات';

  @override
  String get addAccountTitle => 'إضافة حساب';

  @override
  String get editAccountTitle => 'تعديل الحساب';

  @override
  String get accountNameLabel => 'الاسم';

  @override
  String get accountNameHint => 'مثال: فيزا، محفظة نقدية';

  @override
  String get enterAccountName => 'أدخل اسمًا';

  @override
  String get accountTypeLabel => 'النوع';

  @override
  String get accountTypeCard => 'بطاقة';

  @override
  String get accountTypeCash => 'نقدًا';

  @override
  String get accountInitialBalanceLabel => 'الرصيد الابتدائي';

  @override
  String get enterValidAmount => 'أدخل مبلغًا صحيحًا';

  @override
  String get accountColorLabel => 'اللون';

  @override
  String couldNotSaveAccount(Object error) {
    return 'تعذّر حفظ الحساب: $error';
  }

  @override
  String couldNotLoadAccounts(Object error) {
    return 'تعذّر تحميل الحسابات: $error';
  }

  @override
  String get noAccountsYet =>
      'لا توجد حسابات بعد.\nاضغط + لإضافة بطاقة أو نقد.';

  @override
  String get totalBalance => 'الرصيد الإجمالي';

  @override
  String get archiveAccount => 'أرشفة الحساب';

  @override
  String get unarchiveAccount => 'إلغاء أرشفة الحساب';

  @override
  String get accountArchived => 'تمت أرشفة هذا الحساب.';

  @override
  String get noTransfersYet => 'لا توجد تحويلات بعد.\nاضغط + لتسجيل واحدة.';

  @override
  String couldNotLoadTransfers(Object error) {
    return 'تعذّر تحميل التحويلات: $error';
  }

  @override
  String get addTransferTitle => 'إضافة تحويل';

  @override
  String get transferToLabel => 'تحويل إلى';

  @override
  String get transferToAccount => 'حسابي';

  @override
  String get transferToPerson => 'شخص آخر';

  @override
  String get transferToAccountLabel => 'إلى حساب';

  @override
  String get noOtherAccounts => 'أضف حسابًا آخر أولاً';

  @override
  String get recipientNameLabel => 'اسم المستلم';

  @override
  String get receiptLabel => 'إيصال';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String get enterRecipientName => 'أدخل اسم المستلم';

  @override
  String couldNotSaveTransfer(Object error) {
    return 'تعذّر حفظ التحويل: $error';
  }

  @override
  String transferToName(String name) {
    return 'إلى $name';
  }

  @override
  String transferFromName(String name) {
    return 'من $name';
  }

  @override
  String get paidFromLabel => 'الدفع من';

  @override
  String get paidFromNone => 'بدون';

  @override
  String get showArchivedAccounts => 'إظهار الحسابات المؤرشفة';

  @override
  String get hideArchivedAccounts => 'إخفاء الحسابات المؤرشفة';

  @override
  String get archivedLabel => 'مؤرشف';
}
