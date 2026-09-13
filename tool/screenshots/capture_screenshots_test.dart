// Reusable screenshot tool — NOT part of the real test suite (lives under
// tool/, not test/, so a plain `flutter test` never picks it up).
//
// Renders real app screens headlessly, using the same fake-repository
// override technique the widget tests use, and rasterizes each step to a
// PNG. There is no Android/iOS emulator or browser in this environment, so
// this drives the actual production widget tree through `flutter test`'s
// software renderer instead.
//
// Run:
//   flutter test tool/screenshots/capture_screenshots_test.dart
// Output:
//   $SCREENSHOT_OUT_DIR (default /tmp/app_screenshots)/<flow>/<n>_<name>.png
//
// Add a new flow: copy an existing `testWidgets` block, seed the accounts/
// transactions you need through FakeAccountRepository /
// FakeTransactionRepository directly (no UI needed for setup), then drive
// the real screens with `tester.tap` / `tester.enterText`, calling
// `_capture` wherever you want a frame saved.
//
// Three non-obvious things this file works around — see inline comments
// for exactly where:
//   1. `flutter test`'s headless binding has no real fonts (no Android/iOS
//      OS to supply Roboto), so text/icons paint as solid boxes unless you
//      explicitly load font files via FontLoader.
//   2. Any real async I/O triggered by a widget's fire-and-forget
//      `onPressed` (file writes, `path_provider`, image decoding) does not
//      resolve under the test's fake-async clock — `tester.pumpAndSettle()`
//      alone will hang or return too early. Step out to the real event loop
//      with `tester.runAsync()` instead.
//   3. `image_picker` / `path_provider` have no platform implementation in
//      this headless test binding. Swap `ImagePickerPlatform.instance` /
//      `PathProviderPlatform.instance` — the officially supported testing
//      seam for federated plugins — rather than trying to drive a real
//      camera/gallery picker.
// ignore_for_file: invalid_use_of_visible_for_testing_member
// (SharedPreferences.setMockInitialValues is testing-only by design — this
// file is a test-style driver that just doesn't live under test/, see the
// file header.)
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expensetracker/domain/entities/account.dart';
import 'package:expensetracker/domain/entities/account_transfer.dart';
import 'package:expensetracker/domain/entities/expense.dart';
import 'package:expensetracker/domain/entities/expense_category.dart';
import 'package:expensetracker/main.dart';
import 'package:expensetracker/presentation/providers/account_providers.dart';
import 'package:expensetracker/presentation/providers/app_providers.dart';

import '../../test/domain/fake_account_repository.dart';
import '../../test/domain/fake_transaction_repository.dart';

final _outRoot =
    Platform.environment['SCREENSHOT_OUT_DIR'] ?? '/tmp/app_screenshots';
final _sampleReceiptPath =
    '${Directory.current.path}/tool/screenshots/fixtures/sample_receipt.png';
final _fakeDocumentsDir =
    '${Directory.systemTemp.path}/expensetracker_screenshot_docs';

/// Real font files bundled with the Flutter engine's own test fixtures —
/// only present when a full engine checkout (not just the `flutter` CLI
/// tarball) is installed. Override with $SCREENSHOT_FONT_ROOT /
/// $SCREENSHOT_ICONS_FONT if your Flutter install keeps them elsewhere;
/// missing files are skipped with a warning rather than failing the run.
final _robotoFont =
    Platform.environment['SCREENSHOT_FONT_ROOT'] ??
    '/opt/flutter-sdk/flutter/engine/src/flutter/txt/third_party/fonts/Roboto-Regular.ttf';
final _materialIconsFont =
    Platform.environment['SCREENSHOT_ICONS_FONT'] ??
    '/opt/flutter-sdk/flutter/engine/src/flutter/tools/font_subset/fixtures/MaterialIcons-Regular.ttf';

Future<void> _loadFont(String family, String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    // ignore: avoid_print
    print('[screenshots] $family not found at $path — text may render as '
        'solid boxes. Point SCREENSHOT_FONT_ROOT/SCREENSHOT_ICONS_FONT at a '
        'real Flutter engine checkout to fix that.');
    return;
  }
  final bytes = await file.readAsBytes();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

/// (1) Load real fonts — must run inside runAsync, see file header.
Future<void> loadRealFonts() {
  return TestWidgetsFlutterBinding.instance.runAsync(() async {
    await _loadFont('Roboto', _robotoFont);
    await _loadFont('MaterialIcons', _materialIconsFont);
  });
}

/// (2) Real async work (file I/O, image decoding) triggered by a
/// fire-and-forget `onPressed` needs the real event loop, repeatedly,
/// before the widget tree settles into its final state.
Future<void> settleWithRealIo(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

/// (3a) Every `image_picker` pick (camera or gallery) resolves to
/// [imagePath], as if the user chose it.
class FakeImagePicker extends ImagePickerPlatform {
  FakeImagePicker(this.imagePath);
  final String imagePath;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async => XFile(imagePath);
}

/// (3b) `path_provider`'s documents directory, pointed at a real, writable
/// temp folder so `ReceiptStorage` can actually copy files there.
class FakeDocumentsDir extends PathProviderPlatform {
  FakeDocumentsDir(this.path);
  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

/// Rasterizes the widget tree wrapped by [repaintKey] and writes it to
/// `$_outRoot/$flow/$name.png`.
Future<void> capture(
  WidgetTester tester,
  GlobalKey repaintKey,
  String flow,
  String name,
) async {
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$_outRoot/$flow/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(byteData!.buffer.asUint8List());
  });
}

/// Sets a phone-sized surface and registers the fake platforms. Call once
/// at the top of each `testWidgets` body.
void setPhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Pumps [ExpenseTrackerApp] wrapped in a [RepaintBoundary] (for [capture])
/// with the given fakes swapped in for the real SQLite-backed providers.
Future<void> pumpApp(
  WidgetTester tester,
  GlobalKey repaintKey, {
  required FakeTransactionRepository transactions,
  required FakeAccountRepository accounts,
}) {
  return tester.pumpWidget(
    RepaintBoundary(
      key: repaintKey,
      child: ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(transactions),
          accountRepositoryProvider.overrideWithValue(accounts),
        ],
        child: const ExpenseTrackerApp(),
      ),
    ),
  );
}

void main() {
  late FakeTransactionRepository repository;
  late FakeAccountRepository accountRepository;

  setUp(() {
    repository = FakeTransactionRepository();
    accountRepository = FakeAccountRepository();
    SharedPreferences.setMockInitialValues({});
    ImagePickerPlatform.instance = FakeImagePicker(_sampleReceiptPath);
    PathProviderPlatform.instance = FakeDocumentsDir(_fakeDocumentsDir);
  });

  testWidgets('overview: dashboard, accounts, add account, account detail', (
    tester,
  ) async {
    const flow = 'overview';
    await loadRealFonts();
    setPhoneSurface(tester);
    final repaintKey = GlobalKey();

    final visaId = await accountRepository.insertAccount(
      Account(
        name: 'Visa',
        type: AccountType.card,
        initialBalance: 1500,
        colorValue: 0xFF1565C0,
        createdAt: DateTime(2026, 8, 1),
      ),
    );
    final cashId = await accountRepository.insertAccount(
      Account(
        name: 'Cash',
        type: AccountType.cash,
        initialBalance: 200,
        colorValue: 0xFF2E7D32,
        createdAt: DateTime(2026, 8, 1),
      ),
    );
    final now = DateTime.now();
    final lunchId = await repository.insertTransaction(
      Expense(
        amount: 12.5,
        category: ExpenseCategory.food,
        date: DateTime(now.year, now.month, now.day, 12, 30),
        note: 'Lunch with the team',
      ),
    );
    await accountRepository.setExpenseAccount(lunchId, visaId);
    await repository.insertTransaction(
      Expense(
        amount: 40,
        category: ExpenseCategory.transport,
        date: DateTime(now.year, now.month, now.day, 9, 0),
        note: 'Ride to the airport',
      ),
    );
    await accountRepository.insertTransfer(
      AccountTransfer(
        fromAccountId: visaId,
        toAccountId: cashId,
        amount: 300,
        note: 'Weekend cash',
        date: DateTime(now.year, now.month, now.day, 10, 0),
      ),
    );

    await pumpApp(
      tester,
      repaintKey,
      transactions: repository,
      accounts: accountRepository,
    );

    await capture(tester, repaintKey, flow, '1_home_dashboard');

    await tester.tap(find.byTooltip('Accounts'));
    await capture(tester, repaintKey, flow, '2_accounts_screen');

    await tester.tap(find.byTooltip('Add account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('account-name')), 'Mastercard');
    await tester.enterText(
      find.byKey(const Key('account-initial-balance')),
      '750',
    );
    await capture(tester, repaintKey, flow, '3_add_account_screen');
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Visa'));
    await capture(tester, repaintKey, flow, '4_account_detail_screen');
  });

  testWidgets('transfer between your own accounts (Visa -> Cash)', (
    tester,
  ) async {
    const flow = 'visa_to_cash';
    await loadRealFonts();
    setPhoneSurface(tester);
    final repaintKey = GlobalKey();

    await accountRepository.insertAccount(
      Account(
        name: 'Visa',
        type: AccountType.card,
        initialBalance: 1500,
        colorValue: 0xFF1565C0,
        createdAt: DateTime(2026, 8, 1),
      ),
    );
    final cashId = await accountRepository.insertAccount(
      Account(
        name: 'Cash',
        type: AccountType.cash,
        initialBalance: 200,
        colorValue: 0xFF2E7D32,
        createdAt: DateTime(2026, 8, 1),
      ),
    );

    await pumpApp(
      tester,
      repaintKey,
      transactions: repository,
      accounts: accountRepository,
    );

    await tester.tap(find.byTooltip('Accounts'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '1_accounts_before');

    await tester.tap(find.text('Visa'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '2_visa_before');

    await tester.tap(find.byTooltip('Add transfer'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('transfer-amount')), '300');
    await tester.enterText(
      find.byKey(const Key('transfer-note')),
      'Cash withdrawal',
    );
    await capture(tester, repaintKey, flow, '3_add_transfer_visa_to_cash');

    await tester.tap(find.byKey(const Key('transfer-save')));
    await settleWithRealIo(tester);
    await capture(tester, repaintKey, flow, '4_visa_after');

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('account-$cashId')));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '5_cash_after');
  });

  testWidgets('transfer to someone else, with a receipt attached', (
    tester,
  ) async {
    const flow = 'transfer_to_person';
    await loadRealFonts();
    setPhoneSurface(tester);
    final repaintKey = GlobalKey();

    await accountRepository.insertAccount(
      Account(
        name: 'Visa',
        type: AccountType.card,
        initialBalance: 1500,
        colorValue: 0xFF1565C0,
        createdAt: DateTime(2026, 8, 1),
      ),
    );

    await pumpApp(
      tester,
      repaintKey,
      transactions: repository,
      accounts: accountRepository,
    );

    await tester.tap(find.byTooltip('Accounts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visa'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add transfer'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('transfer-amount')), '150');
    await tester.tap(find.text('Someone else'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('transfer-person-name')),
      'Sara (rent split)',
    );
    await capture(tester, repaintKey, flow, '1_add_transfer_empty');

    await tester.tap(find.byKey(const Key('transfer-pick-gallery')));
    await settleWithRealIo(tester);
    await capture(tester, repaintKey, flow, '2_add_transfer_with_receipt');

    await tester.tap(find.byKey(const Key('transfer-save')));
    await settleWithRealIo(tester);
    await capture(tester, repaintKey, flow, '3_account_detail_after_transfer');

    await tester.tap(find.text('To Sara (rent split)'));
    await settleWithRealIo(tester);
    await capture(tester, repaintKey, flow, '4_receipt_full_view');
  });

  testWidgets('accounts list with an archived account shown', (
    tester,
  ) async {
    const flow = 'archived_accounts';
    await loadRealFonts();
    setPhoneSurface(tester);
    final repaintKey = GlobalKey();

    await accountRepository.insertAccount(
      Account(
        name: 'Visa',
        type: AccountType.card,
        initialBalance: 1500,
        colorValue: 0xFF1565C0,
        createdAt: DateTime(2026, 8, 1),
      ),
    );
    // Seeded already-archived, no need to archive it through the UI.
    await accountRepository.insertAccount(
      Account(
        name: 'Old Prepaid Card',
        type: AccountType.card,
        initialBalance: 50,
        colorValue: 0xFFC62828,
        archived: true,
        createdAt: DateTime(2025, 1, 1),
      ),
    );

    await pumpApp(
      tester,
      repaintKey,
      transactions: repository,
      accounts: accountRepository,
    );

    await tester.tap(find.byTooltip('Accounts'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '1_archived_hidden_by_default');

    await tester.tap(find.byTooltip('Show archived accounts'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '2_archived_shown');
  });

  testWidgets('archive / unarchive an account from its detail screen', (
    tester,
  ) async {
    const flow = 'archive_toggle';
    await loadRealFonts();
    setPhoneSurface(tester);
    final repaintKey = GlobalKey();

    await accountRepository.insertAccount(
      Account(
        name: 'Visa',
        type: AccountType.card,
        initialBalance: 1500,
        colorValue: 0xFF1565C0,
        createdAt: DateTime(2026, 8, 1),
      ),
    );

    await pumpApp(
      tester,
      repaintKey,
      transactions: repository,
      accounts: accountRepository,
    );

    await tester.tap(find.byTooltip('Accounts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visa'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '1_detail_active');

    // Archiving pops back to the accounts list, since the account
    // disappears from the default (non-archived) view.
    await tester.tap(find.byTooltip('Archive account'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '2_accounts_after_archive');

    await tester.tap(find.byTooltip('Show archived accounts'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '3_accounts_showing_archived');

    await tester.tap(find.text('Visa'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '4_detail_archived');

    // Unarchiving stays on the detail screen.
    await tester.tap(find.byTooltip('Unarchive account'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '5_detail_after_unarchive');
  });

  testWidgets('edit an existing account', (tester) async {
    const flow = 'edit_account';
    await loadRealFonts();
    setPhoneSurface(tester);
    final repaintKey = GlobalKey();

    await accountRepository.insertAccount(
      Account(
        name: 'Visa',
        type: AccountType.card,
        initialBalance: 1500,
        colorValue: 0xFF1565C0,
        createdAt: DateTime(2026, 8, 1),
      ),
    );

    await pumpApp(
      tester,
      repaintKey,
      transactions: repository,
      accounts: accountRepository,
    );

    await tester.tap(find.byTooltip('Accounts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visa'));
    await tester.pumpAndSettle();

    // Prefilled from the existing account: name, type, starting balance.
    await tester.tap(find.byTooltip('Edit account'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '1_edit_prefilled');

    await tester.enterText(
      find.byKey(const Key('account-name')),
      'Visa Platinum',
    );
    await tester.enterText(
      find.byKey(const Key('account-initial-balance')),
      '1800',
    );
    await capture(tester, repaintKey, flow, '2_edit_changed');

    await tester.tap(find.byKey(const Key('account-save')));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '3_detail_after_edit');
  });

  testWidgets('edit an existing expense', (tester) async {
    const flow = 'edit_expense';
    await loadRealFonts();
    setPhoneSurface(tester);
    final repaintKey = GlobalKey();

    final visaId = await accountRepository.insertAccount(
      Account(
        name: 'Visa',
        type: AccountType.card,
        initialBalance: 1500,
        colorValue: 0xFF1565C0,
        createdAt: DateTime(2026, 8, 1),
      ),
    );
    final now = DateTime.now();
    final lunchId = await repository.insertTransaction(
      Expense(
        amount: 12.5,
        category: ExpenseCategory.food,
        date: DateTime(now.year, now.month, now.day, 12, 30),
        note: 'Lunch with the team',
      ),
    );
    await accountRepository.setExpenseAccount(lunchId, visaId);

    await pumpApp(
      tester,
      repaintKey,
      transactions: repository,
      accounts: accountRepository,
    );
    await tester.pumpAndSettle();

    // Prefilled from the existing expense: amount, category, note, date,
    // and the linked "paid from" account.
    await tester.tap(find.text('Lunch with the team'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '1_edit_prefilled');

    await tester.enterText(find.byKey(const Key('expense-amount')), '18');
    await tester.tap(find.byKey(const Key('category-transport')));
    await tester.enterText(
      find.byKey(const Key('expense-note')),
      'Lunch + taxi back',
    );
    await capture(tester, repaintKey, flow, '2_edit_changed');

    await tester.tap(find.byKey(const Key('expense-save')));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '3_dashboard_after_edit');
  });

  testWidgets('delete an expense, with undo', (tester) async {
    const flow = 'delete_expense';
    await loadRealFonts();
    setPhoneSurface(tester);
    final repaintKey = GlobalKey();

    final now = DateTime.now();
    final lunchId = await repository.insertTransaction(
      Expense(
        amount: 12.5,
        category: ExpenseCategory.food,
        date: DateTime(now.year, now.month, now.day, 12, 30),
        note: 'Lunch with the team',
      ),
    );
    await repository.insertTransaction(
      Expense(
        amount: 40,
        category: ExpenseCategory.transport,
        date: DateTime(now.year, now.month, now.day, 9, 0),
        note: 'Ride to the airport',
      ),
    );

    await pumpApp(
      tester,
      repaintKey,
      transactions: repository,
      accounts: accountRepository,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '1_history_before');

    // Swipe the Lunch row away (Dismissible, direction: endToStart).
    await tester.drag(
      find.byKey(Key('transaction-$lunchId')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '2_deleted_with_undo_snackbar');

    await tester.tap(find.byKey(const Key('undo-delete')));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '3_restored_after_undo');
  });

  testWidgets('filter history by a date range', (tester) async {
    const flow = 'history_date_filter';
    await loadRealFonts();
    setPhoneSurface(tester);
    final repaintKey = GlobalKey();

    // All within the current month so the default single-month calendar
    // view can select them without paging.
    final now = DateTime.now();
    Future<void> seed(int day, String note) => repository.insertTransaction(
      Expense(
        amount: 20,
        category: ExpenseCategory.food,
        date: DateTime(now.year, now.month, day, 12),
        note: note,
      ),
    );
    await seed(1, 'Early in the month');
    await seed(10, 'Range start');
    await seed(15, 'Middle of range');
    await seed(25, 'Late in the month');

    await pumpApp(
      tester,
      repaintKey,
      transactions: repository,
      accounts: accountRepository,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '1_history_unfiltered');

    await tester.tap(find.byKey(const Key('history-date-filter')));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '2_date_range_picker_open');

    // Pick day 10 as the start and day 20 as the end of the range. The
    // range picker keeps adjacent months mounted in its scrollable, so
    // several equal day-number Texts can exist at once — `.first` is the
    // current (visible) page's cell.
    await tester.tap(find.text('10').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('20').first);
    await tester.pumpAndSettle();
    // The range picker's confirm action is labeled "Save" (the single-date
    // picker instead uses "OK" — different Material localizations).
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '3_history_filtered');

    // Chip's own tap target only covers its label; the delete affordance
    // is the separate cancel icon it renders (no custom deleteIcon set).
    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '4_filter_cleared');
  });

  testWidgets('filter an account detail\'s transfers by a date range', (
    tester,
  ) async {
    const flow = 'account_date_filter';
    await loadRealFonts();
    setPhoneSurface(tester);
    final repaintKey = GlobalKey();

    final visaId = await accountRepository.insertAccount(
      Account(
        name: 'Visa',
        type: AccountType.card,
        initialBalance: 1500,
        colorValue: 0xFF1565C0,
        createdAt: DateTime(2026, 8, 1),
      ),
    );
    final cashId = await accountRepository.insertAccount(
      Account(
        name: 'Cash',
        type: AccountType.cash,
        initialBalance: 200,
        colorValue: 0xFF2E7D32,
        createdAt: DateTime(2026, 8, 1),
      ),
    );

    // All within the current month so the default single-month calendar
    // view can select them without paging.
    final now = DateTime.now();
    Future<void> seed(int day, double amount, String note) =>
        accountRepository.insertTransfer(
          AccountTransfer(
            fromAccountId: visaId,
            toAccountId: cashId,
            amount: amount,
            note: note,
            date: DateTime(now.year, now.month, day, 12),
          ),
        );
    await seed(1, 50, 'Early in the month');
    await seed(10, 100, 'Range start');
    await seed(15, 75, 'Middle of range');
    await seed(25, 60, 'Late in the month');

    await pumpApp(
      tester,
      repaintKey,
      transactions: repository,
      accounts: accountRepository,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Accounts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visa'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '1_detail_unfiltered');

    await tester.tap(find.byKey(const Key('account-date-filter')));
    await tester.pumpAndSettle();

    // Pick day 10 as the start and day 20 as the end of the range. The
    // range picker keeps adjacent months mounted in its scrollable, so
    // `.first` targets the current (visible) page's cell; its confirm
    // action is labeled "Save" (not "OK", which is the single-date
    // picker's label).
    await tester.tap(find.text('10').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('20').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '2_detail_filtered');

    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '3_detail_filter_cleared');
  });

  testWidgets('filter the dashboard by a date range', (tester) async {
    const flow = 'dashboard_date_filter';
    await loadRealFonts();
    setPhoneSurface(tester);
    final repaintKey = GlobalKey();

    // All within the current month so the default single-month calendar
    // view can select them without paging.
    final now = DateTime.now();
    Future<void> seed(int day, ExpenseCategory category, String note) =>
        repository.insertTransaction(
          Expense(
            amount: 20,
            category: category,
            date: DateTime(now.year, now.month, day, 12),
            note: note,
          ),
        );
    await seed(1, ExpenseCategory.food, 'Early in the month');
    await seed(10, ExpenseCategory.transport, 'Range start');
    await seed(15, ExpenseCategory.transport, 'Middle of range');
    await seed(25, ExpenseCategory.food, 'Late in the month');

    await pumpApp(
      tester,
      repaintKey,
      transactions: repository,
      accounts: accountRepository,
    );
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '1_dashboard_unfiltered');

    await tester.tap(find.byKey(const Key('dashboard-date-filter')));
    await tester.pumpAndSettle();

    // Pick day 10 as the start and day 20 as the end of the range. The
    // range picker keeps adjacent months mounted in its scrollable, so
    // `.first` targets the current (visible) page's cell; its confirm
    // action is labeled "Save" (not "OK", which is the single-date
    // picker's label).
    await tester.tap(find.text('10').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('20').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '2_dashboard_filtered');

    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pumpAndSettle();
    await capture(tester, repaintKey, flow, '3_dashboard_filter_cleared');
  });
}
