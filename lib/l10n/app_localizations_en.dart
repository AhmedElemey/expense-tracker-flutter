// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ExpenseTracker';

  @override
  String get historyTooltip => 'History';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get addExpenseTooltip => 'Add expense';

  @override
  String get previousMonthTooltip => 'Previous month';

  @override
  String get nextMonthTooltip => 'Next month';

  @override
  String get spentThisMonth => 'Spent this month';

  @override
  String get thisMonth => 'This month';

  @override
  String categoryThisMonth(String category) {
    return '$category this month';
  }

  @override
  String get noExpensesThisMonth =>
      'No expenses this month.\nTap + to add one.';

  @override
  String noCategoryExpensesThisMonth(String category) {
    return 'No $category expenses this month.';
  }

  @override
  String get noSpendingToChart => 'No spending to chart this month.';

  @override
  String couldNotLoadTotals(Object error) {
    return 'Could not load totals: $error';
  }

  @override
  String couldNotLoadExpenses(Object error) {
    return 'Could not load expenses: $error';
  }

  @override
  String couldNotLoadHistory(Object error) {
    return 'Could not load history: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get historyTitle => 'History';

  @override
  String get groupByDay => 'Day';

  @override
  String get groupByMonth => 'Month';

  @override
  String get noExpensesYet => 'No expenses yet.\nAdd one from the home screen.';

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get undo => 'Undo';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get removeAdsTitle => 'Remove Ads';

  @override
  String get removeAdsSubtitle => 'Hide the dashboard banner on this device';

  @override
  String get currencyTitle => 'Currency';

  @override
  String get currencySubtitle => 'Shown on totals, lists, and the expense form';

  @override
  String get currencyEgyptianPound => 'Egyptian Pound';

  @override
  String get currencyDollar => 'Dollar';

  @override
  String get currencyEuro => 'Euro';

  @override
  String get currencyPound => 'Sterling';

  @override
  String get currencyYen => 'Yen';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'English or Arabic — used for the whole app';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get exportData => 'Export data';

  @override
  String get exportDataSubtitle => 'Share all expenses as a CSV file';

  @override
  String get importData => 'Import data';

  @override
  String get importDataSubtitle => 'Add expenses from a CSV export';

  @override
  String exportFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String importFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String importResult(int inserted, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: 'Imported $inserted, skipped $skipped duplicates.',
      one: 'Imported $inserted, skipped 1 duplicate.',
    );
    return '$_temp0';
  }

  @override
  String get exportShareSubject => 'ExpenseTracker export';

  @override
  String get addExpenseTitle => 'Add expense';

  @override
  String get editExpenseTitle => 'Edit expense';

  @override
  String get amountLabel => 'Amount';

  @override
  String get amountHint => '0.00';

  @override
  String get dateLabel => 'Date';

  @override
  String get categoryLabel => 'Category';

  @override
  String get customCategoryLabel => 'Custom category';

  @override
  String get customCategoryHint => 'e.g. Gym, gifts…';

  @override
  String get enterCustomCategory => 'Enter a category name';

  @override
  String get noteLabel => 'Note (optional)';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saving => 'Saving…';

  @override
  String get enterAmount => 'Enter an amount';

  @override
  String get amountMustBePositive => 'Amount must be greater than 0';

  @override
  String couldNotSaveExpense(Object error) {
    return 'Could not save expense: $error';
  }

  @override
  String showAllTotal(String amount) {
    return 'Show all · $amount total';
  }

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryBills => 'Bills';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryOther => 'Other';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get addAccountTitle => 'Add account';

  @override
  String get editAccountTitle => 'Edit account';

  @override
  String get accountNameLabel => 'Name';

  @override
  String get accountNameHint => 'e.g. Visa, Cash wallet';

  @override
  String get enterAccountName => 'Enter a name';

  @override
  String get accountTypeLabel => 'Type';

  @override
  String get accountTypeCard => 'Card';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountInitialBalanceLabel => 'Starting balance';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get accountColorLabel => 'Color';

  @override
  String couldNotSaveAccount(Object error) {
    return 'Could not save account: $error';
  }

  @override
  String couldNotLoadAccounts(Object error) {
    return 'Could not load accounts: $error';
  }

  @override
  String get noAccountsYet => 'No accounts yet.\nTap + to add a card or cash.';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get archiveAccount => 'Archive account';

  @override
  String get unarchiveAccount => 'Unarchive account';

  @override
  String get accountArchived => 'This account was archived.';

  @override
  String get noTransfersYet => 'No transfers yet.\nTap + to record one.';

  @override
  String couldNotLoadTransfers(Object error) {
    return 'Could not load transfers: $error';
  }

  @override
  String get addTransferTitle => 'Add transfer';

  @override
  String get transferToLabel => 'Transfer to';

  @override
  String get transferToAccount => 'My account';

  @override
  String get transferToPerson => 'Someone else';

  @override
  String get transferToAccountLabel => 'To account';

  @override
  String get noOtherAccounts => 'Add another account first';

  @override
  String get recipientNameLabel => 'Recipient name';

  @override
  String get receiptLabel => 'Receipt';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get enterRecipientName => 'Enter the recipient\'s name';

  @override
  String couldNotSaveTransfer(Object error) {
    return 'Could not save transfer: $error';
  }

  @override
  String transferToName(String name) {
    return 'To $name';
  }

  @override
  String transferFromName(String name) {
    return 'From $name';
  }

  @override
  String get paidFromLabel => 'Paid from';

  @override
  String get paidFromNone => 'None';

  @override
  String get showArchivedAccounts => 'Show archived accounts';

  @override
  String get hideArchivedAccounts => 'Hide archived accounts';

  @override
  String get archivedLabel => 'Archived';

  @override
  String get filterByDateTooltip => 'Filter by date';

  @override
  String get clearDateFilterTooltip => 'Clear date filter';

  @override
  String get noExpensesInRange => 'No expenses in this date range.';

  @override
  String get noTransfersInRange => 'No transfers in this date range.';

  @override
  String get spentInRange => 'Spent in this range';

  @override
  String get inThisRange => 'In this range';

  @override
  String categoryInRange(String category) {
    return '$category in this range';
  }
}
