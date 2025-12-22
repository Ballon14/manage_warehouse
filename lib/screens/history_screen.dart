import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stock_provider.dart';
import '../models/stock_move_model.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_skeleton.dart';
import '../services/export_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _isExporting = false;

  Future<void> _exportTransactions(List<StockMoveModel> transactions) async {
    if (_isExporting || transactions.isEmpty) return;

    setState(() => _isExporting = true);

    try {
      // Generate CSV content
      final csvContent = ExportService.generateTransactionCSV(transactions);
      
      // Generate filename
      final filename = ExportService.generateTransactionFilename();
      
      // Export to file
      await ExportService.exportToFile(filename, csvContent);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export berhasil: $filename'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export gagal: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockMovesAsync = ref.watch(stockMovesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          stockMovesAsync.maybeWhen(
            data: (moves) => moves.isNotEmpty
                ? IconButton(
                    icon: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download),
                    tooltip: 'Export to CSV',
                    onPressed: _isExporting ? null : () => _exportTransactions(moves),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(stockMovesStreamProvider);
        },
        child: stockMovesAsync.when(
          data: (moves) {
            if (moves.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.history_outlined,
                title: 'Belum Ada Riwayat',
                message: 'Belum ada transaksi stock yang tercatat. Transaksi inbound dan outbound akan muncul di sini.',
              );
            }

            return ListView.builder(
              itemCount: moves.length,
              itemBuilder: (context, index) {
                final move = moves[index];
                final isInbound = move.type == StockMoveType.inbound;
                final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isInbound ? Colors.green : Colors.orange,
                      child: Icon(
                        isInbound ? Icons.arrow_downward : Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    ),
                    title: Text('Item: ${move.itemId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity: ${move.qty}'),
                        if (move.locationId != null)
                          Text('Location: ${move.locationId}'),
                        Text('Date: ${dateFormat.format(move.timestamp)}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        isInbound ? 'IN' : 'OUT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: isInbound ? Colors.green : Colors.orange,
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const SkeletonList(
            itemCount: 10,
            itemHeight: 100,
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(stockMovesStreamProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


