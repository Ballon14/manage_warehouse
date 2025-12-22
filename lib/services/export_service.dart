import 'package:intl/intl.dart';
import '../models/item_model.dart';
import '../models/period_filter.dart';
import '../models/stock_move_model.dart';

// Platform-specific stub
import 'export_service_stub.dart'
    if (dart.library.html) 'export_service_web.dart'
    if (dart.library.io) 'export_service_mobile.dart';

class ExportService {
  /// Generate CSV content from items list
  static String generateCSV(List<ItemModel> items, String periodLabel) {
    final csv = StringBuffer();
    
    // Title with period
    csv.writeln('Laporan Data Barang - $periodLabel');
    csv.writeln('Tanggal Export: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    csv.writeln('Total Item: ${items.length}');
    csv.writeln('');
    
    // Header
    csv.writeln('No,Nama Item,SKU,Barcode,Reorder Level,Satuan,Tanggal Dibuat');
    
    // Data rows
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final dateStr = DateFormat('dd/MM/yyyy').format(item.createdAt);
      csv.writeln(
        '${i + 1},"${item.name}","${item.sku}","${item.barcode ?? '-'}",${item.reorderLevel},"${item.uom}","$dateStr"'
      );
    }
    
    return csv.toString();
  }

  /// Export to file - delegates to platform-specific implementation
  static Future<void> exportToFile(String filename, String content) async {
    await exportPlatformFile(filename, content);
  }

  /// Generate filename with period and timestamp
  static String generateFilename(ReportPeriod period) {
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final periodStr = period.label.replaceAll(' ', '_');
    return 'Laporan_Barang_${periodStr}_$dateStr.csv';
  }

  /// Generate CSV content from transaction/stock movement list
  static String generateTransactionCSV(List<StockMoveModel> transactions) {
    final csv = StringBuffer();
    
    // Title
    csv.writeln('Laporan Transaksi Stock');
    csv.writeln('Tanggal Export: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    csv.writeln('Total Transaksi: ${transactions.length}');
    csv.writeln('');
    
    // Header
    csv.writeln('No,Tanggal,Waktu,Type,Item ID,Quantity,Location,User ID');
    
    // Data rows
    for (var i = 0; i < transactions.length; i++) {
      final trans = transactions[i];
      final dateStr = DateFormat('dd/MM/yyyy').format(trans.timestamp);
      final timeStr = DateFormat('HH:mm:ss').format(trans.timestamp);
      final typeStr = trans.type == StockMoveType.inbound ? 'INBOUND' : 'OUTBOUND';
      final location = trans.locationId ?? '-';
      
      csv.writeln(
        '${i + 1},"$dateStr","$timeStr","$typeStr","${trans.itemId}",${trans.qty},"$location","${trans.userId}"'
      );
    }
    
    return csv.toString();
  }

  /// Generate filename for transaction export with timestamp
  static String generateTransactionFilename() {
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'Laporan_Transaksi_$dateStr.csv';
  }
}
