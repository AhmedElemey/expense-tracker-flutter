import 'package:flutter/material.dart';

import 'package:expensetracker/domain/entities/account.dart';

extension AccountTypeVisuals on AccountType {
  IconData get icon => switch (this) {
    AccountType.card => Icons.credit_card,
    AccountType.cash => Icons.payments,
  };
}

/// Preset colors offered when creating/editing an account.
const kAccountColorPalette = <Color>[
  Color(0xFF2E7D32),
  Color(0xFF1565C0),
  Color(0xFF6A1B9A),
  Color(0xFFAD1457),
  Color(0xFFEF6C00),
  Color(0xFF00838F),
  Color(0xFF37474F),
  Color(0xFFC62828),
];
