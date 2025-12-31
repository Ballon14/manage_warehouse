import 'dart:convert';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:csv/csv.dart';
import '../models/item_model.dart';
import '../models/stock_move_model.dart';

/// Service for CSV export and import operations
class CSVService {
  /// Export items to CSV
  static Future<void> exportItemsToCSV(List<ItemModel> items) async {
    // Create CSV header
    List<List<dynamic>> rows = [
      ['SKU', 'Name', 'Barcode', 'Reorder Level', 'UOM', 'Created At'],
    ];

    // Add item data
    for (var item in items) {
      rows.add([
        item.sku,
        item.name,
        item.barcode ?? '',
        item.reorderLevel,
        item.uom,
        item.createdAt.toIso8601String(),
      ]);
    }

    // Convert to CSV
    String csv = const ListToCsvConverter().convert(rows);

    // Download file
    _downloadFile(
      filename: 'items_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      content: csv,
      mimeType: 'text/csv',
    );
  }

  /// Export stock movements to CSV
  static Future<void> exportStockMovesToCSV(
    List<StockMoveModel> moves,
    Map<String, String> itemNames,
  ) async {
    // Create CSV header
    List<List<dynamic>> rows = [
      ['Item', 'Type', 'Quantity', 'Location', 'Timestamp', 'User ID'],
    ];

    // Add movement data
    for (var move in moves) {
      rows.add([
        itemNames[move.itemId] ?? move.itemId,
        move.type.name.toUpperCase(),
        move.qty,
        move.locationId ?? '',
        move.timestamp.toIso8601String(),
        move.userId,
      ]);
    }

    // Convert to CSV
    String csv = const ListToCsvConverter().convert(rows);

    // Download file
    _downloadFile(
      filename: 'stock_movements_${DateTime.now().millisecondsSinceEpoch}.csv',
      content: csv,
      mimeType: 'text/csv',
    );
  }

  static void _downloadFile({
    required String filename,
    required String content,
    required String mimeType,
  }) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  /// Parse CSV file for item import
  static Future<List<Map<String, dynamic>>> parseItemsCSV(
    Uint8List fileBytes,
  ) async {
    final content = utf8.decode(fileBytes);
    final rows = const CsvToListConverter().convert(content);

    if (rows.isEmpty || rows.length < 2) {
      throw Exception('CSV file is empty or has no data rows');
    }

    // Parse data rows (skip header)
    List<Map<String, dynamic>> items = [];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row[0].toString().trim().isEmpty) continue;

      try {
        items.add({
          'sku': row[0].toString().trim(),
          'name': row.length > 1 ? row[1].toString().trim() : '',
          'barcode': row.length > 2 && row[2].toString().isNotEmpty
              ? row[2].toString().trim()
              : null,
          'reorderLevel':
              row.length > 3 ? int.tryParse(row[3].toString()) ?? 0 : 0,
          'uom': row.length > 4 && row[4].toString().isNotEmpty
              ? row[4].toString().trim()
              : null,
        });
      } catch (e) {
        throw Exception('Error parsing row ${i + 1}: $e');
      }
    }

    return items;
  }

  /// Validate imported items
  static Map<String, dynamic> validateImportedItems(
    List<Map<String, dynamic>> items,
  ) {
    List<String> errors = [];
    List<String> warnings = [];
    int validCount = 0;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final rowNumber = i + 2; // +2 because of header and 0-index

      // Validate SKU
      if (item['sku'] == null || item['sku'].isEmpty) {
        errors.add('Row $rowNumber: SKU is required');
        continue;
      }

      // Validate Name
      if (item['name'] == null || item['name'].isEmpty) {
        errors.add('Row $rowNumber: Name is required');
        continue;
      }

      // Check reorder level
      if (item['reorderLevel'] < 0) {
        warnings.add('Row $rowNumber: Reorder level cannot be negative');
      }

      validCount++;
    }

    return {
      'valid': errors.isEmpty,
      'validCount': validCount,
      'totalCount': items.length,
      'errors': errors,
      'warnings': warnings,
    };
  }
}
