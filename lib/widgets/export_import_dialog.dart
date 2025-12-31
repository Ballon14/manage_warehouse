import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/item_provider.dart';
import '../providers/stock_provider.dart';
import '../services/csv_service.dart';
import '../models/item_model.dart';
import '../models/stock_move_model.dart';

/// Dialog for import/export options
class ExportImportDialog extends ConsumerStatefulWidget {
  const ExportImportDialog({super.key});

  @override
  ConsumerState<ExportImportDialog> createState() => _ExportImportDialogState();
}

class _ExportImportDialogState extends ConsumerState<ExportImportDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.import_export,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text('Import / Export'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Export Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.file_download,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Export Data',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.inventory_2),
                  title: const Text('Export Items'),
                  subtitle: const Text('Download all items as CSV'),
                  trailing: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  onTap: _isProcessing ? null : _exportItems,
                ),
                const Divider(height: 8),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.move_to_inbox),
                  title: const Text('Export Stock Movements'),
                  subtitle: const Text('Download movement history as CSV'),
                  trailing: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  onTap: _isProcessing ? null : _exportStockMoves,
                ),
                const Divider(height: 8),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.summarize),
                  title: const Text('Export Stock Summary'),
                  subtitle: const Text('Download current stock levels'),
                  trailing: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  onTap: _isProcessing ? null : _exportStockSummary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Import Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.file_upload,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Import Data',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.inventory_2),
                  title: const Text('Import Items'),
                  subtitle: const Text('Upload CSV file to add items'),
                  trailing: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file),
                  onTap: _isProcessing ? null : _importItems,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _exportItems() async {
    setState(() => _isProcessing = true);
    try {
      final itemsAsync = ref.read(itemsStreamProvider);
      await itemsAsync.when(
        data: (items) async {
          await CSVService.exportItemsToCSV(items);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Exported ${items.length} items successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        loading: () async {
          throw Exception('Data is still loading');
        },
        error: (error, stack) async {
          throw error;
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _exportStockMoves() async {
    setState(() => _isProcessing = true);
    try {
      final movesAsync = ref.read(stockMovesStreamProvider);
      final itemsAsync = ref.read(itemsStreamProvider);

      await Future.wait([
        movesAsync.when(
          data: (moves) async => moves,
          loading: () async => <dynamic>[],
          error: (_, __) async => <dynamic>[],
        ),
        itemsAsync.when(
          data: (items) async => items,
          loading: () async => <ItemModel>[],
          error: (_, __) async => <ItemModel>[],
        ),
      ]).then((results) async {
        final moves = results[0] as List<StockMoveModel>;
        final items = results[1] as List<ItemModel>;

        // Create item name map
        final itemNames = {for (var item in items) item.id: item.name};

        await CSVService.exportStockMovesToCSV(moves, itemNames);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exported ${moves.length} movements successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _exportStockSummary() async {
    setState(() => _isProcessing = true);
    try {
      // This would need actual stock calculation logic
      // For now, showing a placeholder
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock summary export - coming soon'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _importItems() async {
    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isProcessing = true);

      final fileBytes = result.files.first.bytes;
      if (fileBytes == null) {
        throw Exception('Could not read file data');
      }

      // Parse CSV
      final items = await CSVService.parseItemsCSV(fileBytes);

      // Validate items
      final validation = CSVService.validateImportedItems(items);

      if (!validation['valid']) {
        _showValidationDialog(validation);
        return;
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Import'),
          content: Text(
            'Import ${validation['validCount']} items?\n\n'
            '${validation['warnings'].isNotEmpty ? 'Warnings:\n${(validation['warnings'] as List).join('\n')}' : ''}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Import items
      final itemService = ref.read(itemServiceProvider);
      int successCount = 0;

      for (var itemData in items) {
        try {
          final newItem = ItemModel(
            id: '', // Will be set by Firestore
            sku: itemData['sku'],
            name: itemData['name'],
            barcode: itemData['barcode'],
            reorderLevel: itemData['reorderLevel'],
            uom: itemData['uom'] ?? 'pcs',
            createdAt: DateTime.now(),
          );
          await itemService.createItem(newItem);
          successCount++;
        } catch (e) {
          // Skip failed items
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported $successCount items successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showValidationDialog(Map<String, dynamic> validation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Validation Errors'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Found ${(validation['errors'] as List).length} errors:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...(validation['errors'] as List).map(
                (error) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $error'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
