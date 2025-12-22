import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/item_provider.dart';
import '../providers/stock_provider.dart';
import '../models/stock_move_model.dart';
import '../models/stock_level_model.dart';
import 'edit_item_screen.dart';
import 'inbound_screen.dart';
import 'outbound_screen.dart';

class ItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemByIdProvider(itemId));
    final stockLevelsAsync = ref.watch(stockLevelsProvider(itemId));
    final transactionsAsync = ref.watch(itemTransactionsProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          itemAsync.maybeWhen(
            data: (item) => item != null
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditItemScreen(item: item),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: itemAsync.when(
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Item not found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(itemByIdProvider(itemId));
              ref.invalidate(stockLevelsProvider(itemId));
              ref.invalidate(itemTransactionsProvider(itemId));
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                final maxWidth = isDesktop ? 1400.0 : double.infinity;

                return Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Header
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor.withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: EdgeInsets.all(isDesktop ? 32 : 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(isDesktop ? 20 : 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.inventory_2,
                                        size: isDesktop ? 64 : 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              fontSize: isDesktop ? 32 : 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'SKU: ${item.sku}',
                                            style: TextStyle(
                                              fontSize: isDesktop ? 16 : 14,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Stock Status Badge
                                stockLevelsAsync.when(
                                  data: (stockLevels) {
                                    final totalStock = stockLevels.fold<double>(
                                      0,
                                      (sum, stock) => sum + stock.qty,
                                    );
                                    final isLowStock = totalStock <= item.reorderLevel;
                                    final isOutOfStock = totalStock == 0;

                                    Color badgeColor;
                                    String badgeText;
                                    IconData badgeIcon;

                                    if (isOutOfStock) {
                                      badgeColor = Colors.red;
                                      badgeText = 'Out of Stock';
                                      badgeIcon = Icons.error;
                                    } else if (isLowStock) {
                                      badgeColor = Colors.orange;
                                      badgeText = 'Low Stock';
                                      badgeIcon = Icons.warning;
                                    } else {
                                      badgeColor = Colors.green;
                                      badgeText = 'In Stock';
                                      badgeIcon = Icons.check_circle;
                                    }

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: badgeColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(badgeIcon, size: 16, color: Colors.white),
                                          const SizedBox(width: 6),
                                          Text(
                                            badgeText,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),

                          // Main Content - Responsive Layout
                          Padding(
                            padding: EdgeInsets.all(isDesktop ? 24 : 16),
                            child: isDesktop
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Left Column
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildBasicInfo(item, isDesktop),
                                            const SizedBox(height: 24),
                                            const _SectionTitle(title: 'Statistics'),
                                            const SizedBox(height: 12),
                                            _buildStatistics(stockLevelsAsync, transactionsAsync, item.uom),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      // Right Column
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const _SectionTitle(title: 'Stock by Location'),
                                            const SizedBox(height: 12),
                                            _buildStockLevels(stockLevelsAsync, item),
                                            const SizedBox(height: 24),
                                            const _SectionTitle(title: 'Recent Transactions'),
                                            const SizedBox(height: 12),
                                            _buildTransactions(transactionsAsync),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildBasicInfo(item, isDesktop),
                                      const SizedBox(height: 24),
                                      const _SectionTitle(title: 'Statistics'),
                                      const SizedBox(height: 12),
                                      _buildStatistics(stockLevelsAsync, transactionsAsync, item.uom),
                                      const SizedBox(height: 24),
                                      const _SectionTitle(title: 'Stock by Location'),
                                      const SizedBox(height: 12),
                                      _buildStockLevels(stockLevelsAsync, item),
                                      const SizedBox(height: 24),
                                      const _SectionTitle(title: 'Recent Transactions'),
                                      const SizedBox(height: 12),
                                      _buildTransactions(transactionsAsync),
                                      const SizedBox(height: 80), // Space for FAB
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: itemAsync.maybeWhen(
        data: (item) => item != null ? _buildFABMenu(context, item.id) : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildBasicInfo(dynamic item, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Basic Information'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.qr_code,
                  label: 'Barcode',
                  value: item.barcode ?? '-',
                ),
                const Divider(),
                _InfoRow(
                  icon: Icons.scale,
                  label: 'Unit of Measure',
                  value: item.uom,
                ),
                const Divider(),
                _InfoRow(
                  icon: Icons.notification_important,
                  label: 'Reorder Level',
                  value: '${item.reorderLevel.toInt()}',
                ),
                const Divider(),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Created',
                  value: DateFormat('dd MMM yyyy').format(item.createdAt),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(
    AsyncValue<List<StockLevelModel>> stockLevelsAsync,
    AsyncValue<List<StockMoveModel>> transactionsAsync,
    String uom,
  ) {
    return stockLevelsAsync.when(
      data: (stockLevels) {
        final totalStock = stockLevels.fold<double>(
          0,
          (sum, stock) => sum + stock.qty,
        );

        return transactionsAsync.when(
          data: (transactions) {
            final totalInbound = transactions
                .where((t) => t.type == StockMoveType.inbound)
                .fold<double>(0, (sum, t) => sum + t.qty);
            final totalOutbound = transactions
                .where((t) => t.type == StockMoveType.outbound)
                .fold<double>(0, (sum, t) => sum + t.qty);

            return Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.inventory,
                    label: 'Total Stock',
                    value: '${totalStock.toInt()}',
                    unit: uom,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.arrow_downward,
                    label: 'Inbound',
                    value: '${totalInbound.toInt()}',
                    unit: uom,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.arrow_upward,
                    label: 'Outbound',
                    value: '${totalOutbound.toInt()}',
                    unit: uom,
                    color: Colors.orange,
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStockLevels(
    AsyncValue<List<StockLevelModel>> stockLevelsAsync,
    dynamic item,
  ) {
    return stockLevelsAsync.when(
      data: (stockLevels) {
        if (stockLevels.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No stock available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Column(
          children: stockLevels.map((stock) {
            final isLow = stock.qty <= item.reorderLevel;
            final percentage = item.reorderLevel > 0
                ? (stock.qty / (item.reorderLevel * 2)).clamp(0.0, 1.0)
                : 1.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: isLow ? Colors.red : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              stock.locationId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${stock.qty.toInt()} ${item.uom}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isLow ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isLow ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                    if (isLow)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Below reorder level (${item.reorderLevel.toInt()})',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildTransactions(AsyncValue<List<StockMoveModel>> transactionsAsync) {
    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada transaksi',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final displayTransactions = transactions.take(10).toList();

        return Card(
          child: Column(
            children: [
              ...displayTransactions.asMap().entries.map((entry) {
                final index = entry.key;
                final transaction = entry.value;
                final isInbound = transaction.type == StockMoveType.inbound;

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isInbound
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        child: Icon(
                          isInbound ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isInbound ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        isInbound ? 'Inbound' : 'Outbound',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Qty: ${transaction.qty.toInt()}'),
                          if (transaction.locationId != null)
                            Text('Location: ${transaction.locationId}'),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm')
                                .format(transaction.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isInbound ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isInbound ? 'IN' : 'OUT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (index < displayTransactions.length - 1)
                      const Divider(height: 1),
                  ],
                );
              }),
              if (transactions.length > 10)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '+${transactions.length - 10} transaksi lainnya',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.history_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada transaksi',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transaksi akan muncul di sini',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFABMenu(BuildContext context, String itemId) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'inbound',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InboundScreen(),
              ),
            );
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.small(
          heroTag: 'outbound',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OutboundScreen(),
              ),
            );
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.remove),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
