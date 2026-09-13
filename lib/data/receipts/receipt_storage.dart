import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies a picked receipt image into permanent local app storage, since the
/// path the image picker returns can live in an OS temp cache that gets
/// cleared.
class ReceiptStorage {
  const ReceiptStorage();

  Future<String> save(String pickedPath) async {
    final documents = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory(p.join(documents.path, 'receipts'));
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }
    final extension = p.extension(pickedPath);
    final fileName = '${DateTime.now().microsecondsSinceEpoch}$extension';
    final destination = File(p.join(receiptsDir.path, fileName));
    await File(pickedPath).copy(destination.path);
    return destination.path;
  }

  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
