import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ExpenseTracker'**
  String get appTitle;

  /// No description provided for @historyTooltip.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @addExpenseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpenseTooltip;

  /// No description provided for @previousMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonthTooltip;

  /// No description provided for @nextMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonthTooltip;

  /// No description provided for @spentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get spentThisMonth;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @categoryThisMonth.
  ///
  /// In en, this message translates to:
  /// **'{category} this month'**
  String categoryThisMonth(String category);

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month.\nTap + to add one.'**
  String get noExpensesThisMonth;

  /// No description provided for @noCategoryExpensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No {category} expenses this month.'**
  String noCategoryExpensesThisMonth(String category);

  /// No description provided for @noSpendingToChart.
  ///
  /// In en, this message translates to:
  /// **'No spending to chart this month.'**
  String get noSpendingToChart;

  /// No description provided for @couldNotLoadTotals.
  ///
  /// In en, this message translates to:
  /// **'Could not load totals: {error}'**
  String couldNotLoadTotals(Object error);

  /// No description provided for @couldNotLoadExpenses.
  ///
  /// In en, this message translates to:
  /// **'Could not load expenses: {error}'**
  String couldNotLoadExpenses(Object error);

  /// No description provided for @couldNotLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load history: {error}'**
  String couldNotLoadHistory(Object error);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @groupByDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get groupByDay;

  /// No description provided for @groupByMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get groupByMonth;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet.\nAdd one from the home screen.'**
  String get noExpensesYet;

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @removeAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get removeAdsTitle;

  /// No description provided for @removeAdsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide the dashboard banner on this device'**
  String get removeAdsSubtitle;

  /// No description provided for @currencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyTitle;

  /// No description provided for @currencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shown on totals, lists, and the expense form'**
  String get currencySubtitle;

  /// No description provided for @currencyEgyptianPound.
  ///
  /// In en, this message translates to:
  /// **'Egyptian Pound'**
  String get currencyEgyptianPound;

  /// No description provided for @currencyDollar.
  ///
  /// In en, this message translates to:
  /// **'Dollar'**
  String get currencyDollar;

  /// No description provided for @currencyEuro.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyEuro;

  /// No description provided for @currencyPound.
  ///
  /// In en, this message translates to:
  /// **'Sterling'**
  String get currencyPound;

  /// No description provided for @currencyYen.
  ///
  /// In en, this message translates to:
  /// **'Yen'**
  String get currencyYen;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English or Arabic — used for the whole app'**
  String get languageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share all expenses as a CSV file'**
  String get exportDataSubtitle;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importData;

  /// No description provided for @importDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add expenses from a CSV export'**
  String get importDataSubtitle;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(Object error);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(Object error);

  /// No description provided for @importResult.
  ///
  /// In en, this message translates to:
  /// **'{skipped, plural, =1{Imported {inserted}, skipped 1 duplicate.} other{Imported {inserted}, skipped {skipped} duplicates.}}'**
  String importResult(int inserted, int skipped);

  /// No description provided for @exportShareSubject.
  ///
  /// In en, this message translates to:
  /// **'ExpenseTracker export'**
  String get exportShareSubject;

  /// No description provided for @addExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpenseTitle;

  /// No description provided for @editExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpenseTitle;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get amountHint;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @customCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom category'**
  String get customCategoryLabel;

  /// No description provided for @customCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Gym, gifts…'**
  String get customCategoryHint;

  /// No description provided for @enterCustomCategory.
  ///
  /// In en, this message translates to:
  /// **'Enter a category name'**
  String get enterCustomCategory;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get enterAmount;

  /// No description provided for @amountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountMustBePositive;

  /// No description provided for @couldNotSaveExpense.
  ///
  /// In en, this message translates to:
  /// **'Could not save expense: {error}'**
  String couldNotSaveExpense(Object error);

  /// No description provided for @showAllTotal.
  ///
  /// In en, this message translates to:
  /// **'Show all · {amount} total'**
  String showAllTotal(String amount);

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get categoryBills;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @accountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsTitle;

  /// No description provided for @addAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccountTitle;

  /// No description provided for @editAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccountTitle;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accountNameLabel;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Visa, Cash wallet'**
  String get accountNameHint;

  /// No description provided for @enterAccountName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterAccountName;

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get accountTypeLabel;

  /// No description provided for @accountTypeCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get accountTypeCard;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountInitialBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting balance'**
  String get accountInitialBalanceLabel;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @accountColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get accountColorLabel;

  /// No description provided for @couldNotSaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not save account: {error}'**
  String couldNotSaveAccount(Object error);

  /// No description provided for @couldNotLoadAccounts.
  ///
  /// In en, this message translates to:
  /// **'Could not load accounts: {error}'**
  String couldNotLoadAccounts(Object error);

  /// No description provided for @noAccountsYet.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet.\nTap + to add a card or cash.'**
  String get noAccountsYet;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// No description provided for @archiveAccount.
  ///
  /// In en, this message translates to:
  /// **'Archive account'**
  String get archiveAccount;

  /// No description provided for @unarchiveAccount.
  ///
  /// In en, this message translates to:
  /// **'Unarchive account'**
  String get unarchiveAccount;

  /// No description provided for @accountArchived.
  ///
  /// In en, this message translates to:
  /// **'This account was archived.'**
  String get accountArchived;

  /// No description provided for @noTransfersYet.
  ///
  /// In en, this message translates to:
  /// **'No transfers yet.\nTap + to record one.'**
  String get noTransfersYet;

  /// No description provided for @couldNotLoadTransfers.
  ///
  /// In en, this message translates to:
  /// **'Could not load transfers: {error}'**
  String couldNotLoadTransfers(Object error);

  /// No description provided for @addTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Add transfer'**
  String get addTransferTitle;

  /// No description provided for @transferToLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer to'**
  String get transferToLabel;

  /// No description provided for @transferToAccount.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get transferToAccount;

  /// No description provided for @transferToPerson.
  ///
  /// In en, this message translates to:
  /// **'Someone else'**
  String get transferToPerson;

  /// No description provided for @transferToAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'To account'**
  String get transferToAccountLabel;

  /// No description provided for @noOtherAccounts.
  ///
  /// In en, this message translates to:
  /// **'Add another account first'**
  String get noOtherAccounts;

  /// No description provided for @recipientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient name'**
  String get recipientNameLabel;

  /// No description provided for @receiptLabel.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receiptLabel;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @enterRecipientName.
  ///
  /// In en, this message translates to:
  /// **'Enter the recipient\'s name'**
  String get enterRecipientName;

  /// No description provided for @couldNotSaveTransfer.
  ///
  /// In en, this message translates to:
  /// **'Could not save transfer: {error}'**
  String couldNotSaveTransfer(Object error);

  /// No description provided for @transferToName.
  ///
  /// In en, this message translates to:
  /// **'To {name}'**
  String transferToName(String name);

  /// No description provided for @transferFromName.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String transferFromName(String name);

  /// No description provided for @paidFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid from'**
  String get paidFromLabel;

  /// No description provided for @paidFromNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get paidFromNone;

  /// No description provided for @showArchivedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Show archived accounts'**
  String get showArchivedAccounts;

  /// No description provided for @hideArchivedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Hide archived accounts'**
  String get hideArchivedAccounts;

  /// No description provided for @archivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedLabel;

  /// No description provided for @filterByDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get filterByDateTooltip;

  /// No description provided for @clearDateFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear date filter'**
  String get clearDateFilterTooltip;

  /// No description provided for @noExpensesInRange.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this date range.'**
  String get noExpensesInRange;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
