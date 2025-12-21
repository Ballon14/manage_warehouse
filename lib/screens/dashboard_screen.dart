import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/stock_provider.dart';
import '../models/stock_move_model.dart';
import 'items_screen.dart';
import 'scan_screen.dart';
import 'inbound_screen.dart';
import 'outbound_screen.dart';
import 'stock_opname_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'item_report_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final stockMovesAsync = ref.watch(stockMovesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(stockMovesStreamProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 48),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user?.name ?? 'User'}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              user?.email ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stock Movement Statistics
              stockMovesAsync.when(
                data: (moves) {
                  final stats = _calculateStats(moves);
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perpindahan Barang',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _StatsCard(
                              title: 'Total Inbound',
                              value: stats['inboundQty']!.toStringAsFixed(0),
                              icon: Icons.arrow_downward,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatsCard(
                              title: 'Total Outbound',
                              value: stats['outboundQty']!.toStringAsFixed(0),
                              icon: Icons.arrow_upward,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Bar Chart
                      if (moves.isNotEmpty)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final chartHeight = constraints.maxWidth < 360
                                ? 180.0
                                : constraints.maxWidth < 600
                                    ? 200.0
                                    : constraints.maxWidth < 840
                                        ? 250.0
                                        : 300.0;
                            
                            return _StockMovementChart(
                              inboundQty: stats['inboundQty']!,
                              outboundQty: stats['outboundQty']!,
                              height: chartHeight,
                            );
                          },
                        ),
                      
                      const SizedBox(height: 24),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 360
                      ? 2
                      : constraints.maxWidth < 600
                          ? 2
                          : constraints.maxWidth < 840
                              ? 3
                              : 4;
                  
                  final aspectRatio = constraints.maxWidth < 360 
                      ? 1.2 
                      : constraints.maxWidth < 600 
                          ? 1.3 
                          : 1.4;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: aspectRatio,
                    children: [
                  _ActionCard(
                    icon: Icons.qr_code_scanner,
                    title: 'Scan',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScanScreen()),
                      );
                    },
                  ),
                  _ActionCard(
                    icon: Icons.add_box,
                    title: 'Inbound',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const InboundScreen()),
                      );
                    },
                  ),
                  _ActionCard(
                    icon: Icons.remove_circle,
                    title: 'Outbound',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OutboundScreen()),
                      );
                    },
                  ),
                  _ActionCard(
                    icon: Icons.inventory_2,
                    title: 'Stock Opname',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StockOpnameScreen()),
                      );
                    },
                  ),
                  _ActionCard(
                    icon: Icons.description,
                    title: 'Laporan Barang',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ItemReportScreen()),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

              // Recent transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen()),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              stockMovesAsync.when(
                data: (moves) {
                  if (moves.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('No transactions yet')),
                      ),
                    );
                  }
                  return Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: moves.length > 5 ? 5 : moves.length,
                      itemBuilder: (context, index) {
                        final move = moves[index];
                        return ListTile(
                          leading: Icon(
                            move.type == StockMoveType.inbound
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: move.type == StockMoveType.inbound
                                ? Colors.green
                                : Colors.orange,
                          ),
                          title: Text('Item: ${move.itemId}'),
                          subtitle: Text(
                            'Qty: ${move.qty} • ${_formatDate(move.timestamp)}',
                          ),
                          trailing: Text(
                            move.type == StockMoveType.inbound ? 'IN' : 'OUT',
                            style: TextStyle(
                              color: move.type == StockMoveType.inbound
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: $error'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Items section
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('View All Items'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ItemsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Map<String, double> _calculateStats(List<StockMoveModel> moves) {
    double inboundQty = 0;
    double outboundQty = 0;

    for (var move in moves) {
      if (move.type == StockMoveType.inbound) {
        inboundQty += move.qty;
      } else {
        outboundQty += move.qty;
      }
    }

    return {
      'inboundQty': inboundQty,
      'outboundQty': outboundQty,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockMovementChart extends StatelessWidget {
  final double inboundQty;
  final double outboundQty;
  final double height;

  const _StockMovementChart({
    required this.inboundQty,
    required this.outboundQty,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = (inboundQty > outboundQty ? inboundQty : outboundQty) * 1.2;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perbandingan Perpindahan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: height,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY > 0 ? maxY : 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('Inbound', style: TextStyle(fontSize: 12)),
                              );
                            case 1:
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('Outbound', style: TextStyle(fontSize: 12)),
                              );
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 0 ? maxY / 5 : 2,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: inboundQty,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: outboundQty,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
