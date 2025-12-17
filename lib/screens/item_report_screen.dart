import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/item_provider.dart';
import '../models/item_model.dart';

class ItemReportScreen extends ConsumerStatefulWidget {
  const ItemReportScreen({super.key});

  @override
  ConsumerState<ItemReportScreen> createState() => _ItemReportScreenState();
}

class _ItemReportScreenState extends ConsumerState<ItemReportScreen> {
  String _sortBy = 'name'; // name, sku, createdAt
  bool _ascending = true;

  List<ItemModel> _getSortedItems(List<ItemModel> items) {
    final sorted = List<ItemModel>.from(items);
    
    switch (_sortBy) {
      case 'name':
        sorted.sort((a, b) => _ascending 
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case 'sku':
        sorted.sort((a, b) => _ascending
            ? a.sku.compareTo(b.sku)
            : b.sku.compareTo(a.sku));
        break;
      case 'createdAt':
        sorted.sort((a, b) => _ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    return sorted;
  }

  String _formatDateIndonesian(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildMobileView(List<ItemModel> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final dateStr = DateFormat('dd/MM/yyyy').format(item.createdAt);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow('SKU', item.sku),
                const SizedBox(height: 8),
                _buildInfoRow('Barcode', item.barcode ?? '-'),
                const SizedBox(height: 8),
                _buildInfoRow('Reorder Level', item.reorderLevel.toString()),
                const SizedBox(height: 8),
                _buildInfoRow('Satuan', item.uom),
                const SizedBox(height: 8),
                _buildInfoRow('Tanggal', dateStr),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableView(List<ItemModel> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Nama Item', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('SKU', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Barcode', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Reorder Level', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Satuan', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Tanggal Dibuat', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final dateStr = DateFormat('dd/MM/yyyy').format(item.createdAt);
            
            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(item.name)),
                DataCell(Text(item.sku)),
                DataCell(Text(item.barcode ?? '-')),
                DataCell(Text(item.reorderLevel.toString())),
                DataCell(Text(item.uom)),
                DataCell(Text(dateStr)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _exportToCSV(List<ItemModel> items) {
    final csv = StringBuffer();
    
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
    
    // Show dialog with CSV data
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export CSV'),
        content: SingleChildScrollView(
          child: SelectableText(
            csv.toString(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              // In a real app, save to file
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copy teks di atas untuk save ke file CSV'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Info'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Data Barang'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (value == _sortBy) {
                  _ascending = !_ascending;
                } else {
                  _sortBy = value;
                  _ascending = true;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(_sortBy == 'name' 
                        ? (_ascending ? Icons.arrow_upward : Icons.arrow_downward)
                        : Icons.sort_by_alpha),
                    const SizedBox(width: 8),
                    const Text('Urutkan Nama'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sku',
                child: Row(
                  children: [
                    Icon(_sortBy == 'sku'
                        ? (_ascending ? Icons.arrow_upward : Icons.arrow_downward)
                        : Icons.qr_code),
                    const SizedBox(width: 8),
                    const Text('Urutkan SKU'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'createdAt',
                child: Row(
                  children: [
                    Icon(_sortBy == 'createdAt'
                        ? (_ascending ? Icons.arrow_upward : Icons.arrow_downward)
                        : Icons.calendar_today),
                    const SizedBox(width: 8),
                    const Text('Urutkan Tanggal'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada data barang', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final sortedItems = _getSortedItems(items);
          final dateNow = _formatDateIndonesian(DateTime.now());

          return Column(
            children: [
              // Report Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Colors.white,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'LAPORAN DATA BARANG',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Warehouse Management System',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tanggal: $dateNow',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Total: ${items.length} Item',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Items List - Responsive
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Use card layout for mobile, table for larger screens
                    final isMobile = constraints.maxWidth < 600;
                    
                    if (isMobile) {
                      return _buildMobileView(sortedItems);
                    } else {
                      return _buildTableView(sortedItems);
                    }
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: itemsAsync.maybeWhen(
        data: (items) => items.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () => _exportToCSV(_getSortedItems(items)),
                icon: const Icon(Icons.download),
                label: const Text('Export CSV'),
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}
