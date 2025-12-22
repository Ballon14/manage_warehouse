import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Mobile-specific export using share functionality
Future<void> exportPlatformFile(String filename, String content) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$filename';
  final file = File(path);
  
  await file.writeAsString(content);
  
  // Share file
  await Share.shareXFiles(
    [XFile(path)],
    text: 'Laporan Data Barang',
  );
}
