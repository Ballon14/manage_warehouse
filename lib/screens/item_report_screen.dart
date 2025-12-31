import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/item_provider.dart';
import '../models/item_model.dart';
import '../models/period_filter.dart';
import '../services/export_service.dart';

class ItemReportScreen extends ConsumerStatefulWidget {
  const ItemReportScreen({super.key});

  @override
  ConsumerState<ItemReportScreen> createState() => _ItemReportScreenState();
}

class _ItemReportScreenState extends ConsumerState<ItemReportScreen> {
  String _sortBy = 'name'; // name, sku, createdAt
  bool _ascending = true;
  ReportPeriod _selectedPeriod = ReportPeriod.all;

  List<ItemModel> _getSortedItems(List<ItemModel> items) {
    final sorted = List<ItemModel>.from(items);

    switch (_sortBy) {
      case 'name':
        sorted.sort((a, b) =>
            _ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
        break;
      case 'sku':
        sorted.sort((a, b) =>
            _ascending ? a.sku.compareTo(b.sku) : b.sku.compareTo(a.sku));
        break;
      case 'createdAt':
        sorted.sort((a, b) => _ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
    }

    return sorted;
  }

  List<ItemModel> _filterByPeriod(List<ItemModel> items) {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case ReportPeriod.today:
        return items.where((item) {
          final itemDate = item.createdAt;
          return itemDate.year == now.year &&
              itemDate.month == now.month &&
              itemDate.day == now.day;
        }).toList();

      case ReportPeriod.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return items
            .where((item) =>
                item.createdAt
                    .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                item.createdAt.isBefore(endOfWeek.add(const Duration(days: 1))))
            .toList();

      case ReportPeriod.thisMonth:
        return items
            .where((item) =>
                item.createdAt.month == now.month &&
                item.createdAt.year == now.year)
            .toList();

      case ReportPeriod.thisYear:
        return items.where((item) => item.createdAt.year == now.year).toList();

      case ReportPeriod.all:
        return items;
    }
  }

  String _formatDateIndonesian(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showPeriodFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Periode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReportPeriod.values.map((period) {
            return ListTile(
              leading: Radio<ReportPeriod>(
                value: period,
                groupValue: _selectedPeriod,
                toggleable: false,
                onChanged: (value) {
                  setState(() => _selectedPeriod = value!);
                  Navigator.pop(context);
                },
              ),
              title: Row(
                children: [
                  Icon(period.icon, size: 20),
                  const SizedBox(width: 12),
                  Text(period.label),
                ],
              ),
              onTap: () {
                setState(() => _selectedPeriod = period);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCSV(List<ItemModel> items) async {
    try {
      // Generate filename with period
      final filename = ExportService.generateFilename(_selectedPeriod);

      // Generate CSV
      final csv = ExportService.generateCSV(items, _selectedPeriod.label);

      // Export to file
      await ExportService.exportToFile(filename, csv);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Laporan berhasil di-export: $filename')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export: $e')),
        );
      }
    }
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth - 32,
              ),
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 12,
                headingRowHeight: 48,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 56,
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
                border: TableBorder(
                  borderRadius: BorderRadius.circular(8),
                  horizontalInside: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                columns: [
                  DataColumn(
                    label: Container(
                      constraints: const BoxConstraints(minWidth: 40),
                      child: const Text(
                        'No',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: const Text(
                        'Nama Item',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      constraints: const BoxConstraints(minWidth: 100),
                      child: const Text(
                        'SKU',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      constraints: const BoxConstraints(minWidth: 120),
                      child: const Text(
                        'Barcode',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      constraints: const BoxConstraints(minWidth: 100),
                      child: const Text(
                        'Reorder Level',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Container(
                      constraints: const BoxConstraints(minWidth: 80),
                      child: const Text(
                        'Satuan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      constraints: const BoxConstraints(minWidth: 110),
                      child: const Text(
                        'Tanggal Dibuat',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                rows: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final dateStr =
                      DateFormat('dd/MM/yyyy').format(item.createdAt);

                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(minWidth: 40),
                          child: Text('${index + 1}'),
                        ),
                      ),
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(minWidth: 150),
                          child: Text(
                            item.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(minWidth: 100),
                          child: Text(item.sku),
                        ),
                      ),
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(minWidth: 120),
                          child: Text(item.barcode ?? '-'),
                        ),
                      ),
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(minWidth: 100),
                          alignment: Alignment.centerRight,
                          child: Text(item.reorderLevel.toString()),
                        ),
                      ),
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(minWidth: 80),
                          child: Text(item.uom),
                        ),
                      ),
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(minWidth: 110),
                          child: Text(dateStr),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Laporan Data Barang', style: TextStyle(fontSize: 18)),
            Text(
              _selectedPeriod.label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Periode',
            onPressed: _showPeriodFilter,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan',
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
                        ? (_ascending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
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
                        ? (_ascending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
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
                        ? (_ascending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
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
          // Apply period filter first
          final filteredItems = _filterByPeriod(items);

          if (filteredItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada data untuk ${_selectedPeriod.label}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (_selectedPeriod != ReportPeriod.all) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _selectedPeriod = ReportPeriod.all);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tampilkan Semua'),
                    ),
                  ],
                ],
              ),
            );
          }

          // Apply sorting
          final sortedItems = _getSortedItems(filteredItems);
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
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Periode: ${_selectedPeriod.label}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Total: ${sortedItems.length} Item',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
        data: (items) {
          final filteredItems = _filterByPeriod(items);
          return filteredItems.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _exportToCSV(_getSortedItems(filteredItems)),
                  icon: const Icon(Icons.download),
                  label: const Text('Export CSV'),
                )
              : null;
        },
        orElse: () => null,
      ),
    );
  }
}
