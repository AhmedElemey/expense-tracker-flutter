import 'package:expensetracker/domain/entities/account.dart';
import 'package:expensetracker/l10n/app_localizations.dart';

extension AccountTypeL10n on AccountType {
  String localizedName(AppLocalizations l10n) {
    return switch (this) {
      AccountType.card => l10n.accountTypeCard,
      AccountType.cash => l10n.accountTypeCash,
    };
  }
}
