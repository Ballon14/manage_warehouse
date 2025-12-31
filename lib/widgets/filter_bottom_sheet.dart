import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/filter_model.dart';
import '../providers/filter_provider.dart';

/// Bottom sheet for advanced filtering
class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  DateTimeRange? _selectedDateRange;
  StockLevelFilter? _selectedStockLevel;
  RangeValues? _stockRange;

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(filterProvider);
    _selectedDateRange = currentFilter.dateRange;
    _selectedStockLevel = currentFilter.stockLevel;

    if (currentFilter.minStock != null || currentFilter.maxStock != null) {
      _stockRange = RangeValues(
        currentFilter.minStock ?? 0,
        currentFilter.maxStock ?? 1000,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Items',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stock Level Filter
                  Text(
                    'Stock Level',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: StockLevelFilter.values.map((level) {
                      final isSelected = _selectedStockLevel == level;
                      return FilterChip(
                        selected: isSelected,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              level.icon,
                              size: 16,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : level.color,
                            ),
                            const SizedBox(width: 4),
                            Text(level.displayName),
                          ],
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedStockLevel = selected ? level : null;
                          });
                        },
                        selectedColor: level.color,
                        checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Date Range Filter
                  Text(
                    'Created Date Range',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _selectedDateRange != null
                          ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                          : 'Select date range',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  if (_selectedDateRange != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedDateRange = null;
                          });
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear date range'),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Stock Quantity Range
                  Text(
                    'Stock Quantity Range',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Min: ${_stockRange?.start.round() ?? 0}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Max: ${_stockRange?.end.round() ?? 1000}',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _stockRange ?? const RangeValues(0, 1000),
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      '${_stockRange?.start.round() ?? 0}',
                      '${_stockRange?.end.round() ?? 1000}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _stockRange = values;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _clearFilters() {
    setState(() {
      _selectedDateRange = null;
      _selectedStockLevel = null;
      _stockRange = null;
    });
  }

  void _applyFilters() {
    final filter = ItemFilter(
      dateRange: _selectedDateRange,
      stockLevel: _selectedStockLevel,
      minStock: _stockRange?.start,
      maxStock: _stockRange?.end,
    );

    ref.read(filterProvider.notifier).applyFilter(filter);
    Navigator.pop(context);
  }
}
