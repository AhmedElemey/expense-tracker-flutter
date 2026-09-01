import '../entities/expense.dart';
import '../entities/expense_category.dart';

class ExpenseCsv {
  static const header = 'id,amount,category,date,note';

  static String encode(List<Expense> expenses) {
    final rows = [
      header,
      for (final expense in expenses)
        [
          expense.id?.toString() ?? '',
          expense.amount.toString(),
          expense.categoryStorage,
          expense.date.toIso8601String(),
          expense.note ?? '',
        ].map(_escape).join(','),
    ];
    return rows.join('\n');
  }

  static List<Expense> decode(String csv) {
    csv = csv.replaceFirst('\uFEFF', '');
    final lines = csv
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      throw const FormatException('CSV is empty');
    }
    final parsedHeader = _parseLine(
      lines.first,
    ).map((h) => h.trim().toLowerCase()).toList();
    if (parsedHeader.join(',') != header) {
      throw const FormatException('Unexpected CSV header');
    }

    return [for (final line in lines.skip(1)) _rowToExpense(_parseLine(line))];
  }

  static Expense _rowToExpense(List<String> fields) {
    if (fields.length < 5) {
      throw const FormatException('CSV row is missing columns');
    }
    final id = int.tryParse(fields[0]);
    final amount = double.tryParse(fields[1]);
    if (amount == null) {
      throw FormatException('Invalid amount: ${fields[1]}');
    }
    final stored = ExpenseCategory.parseStored(fields[2]);
    return Expense(
      id: id,
      amount: amount,
      category: stored.category,
      date: DateTime.parse(fields[3]),
      note: fields[4].isEmpty ? null : fields[4],
      customCategory: stored.customCategory,
    );
  }

  static String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static List<String> _parseLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            buffer.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          buffer.write(char);
        }
      } else if (char == '"') {
        inQuotes = true;
      } else if (char == ',') {
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    fields.add(buffer.toString());
    return fields;
  }
}
