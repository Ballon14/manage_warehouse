import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/item_provider.dart';
import '../providers/stock_provider.dart';

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemByIdProvider(itemId));

    final stockLevelsAsync = ref.watch(stockLevelsProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: itemAsync.when(
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Item not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('SKU: ${item.sku}'),
                        if (item.barcode != null)
                          Text('Barcode: ${item.barcode}'),
                        Text('UOM: ${item.uom}'),
                        Text('Reorder Level: ${item.reorderLevel}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Stock Levels',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                stockLevelsAsync.when(
                  data: (stockLevels) {
                    if (stockLevels.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No stock available'),
                        ),
                      );
                    }
                    return Column(
                      children: stockLevels.map((stock) {
                        final isLow = stock.qty <= item.reorderLevel;
                        return Card(
                          color: isLow ? Colors.red.shade50 : null,
                          child: ListTile(
                            title: Text('Location: ${stock.locationId}'),
                            subtitle:
                                Text('Quantity: ${stock.qty} ${item.uom}'),
                            trailing: isLow
                                ? const Icon(Icons.warning, color: Colors.red)
                                : null,
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
