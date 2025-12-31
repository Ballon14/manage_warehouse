import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../widgets/analytics_charts.dart';

/// Analytics dashboard screen
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateRangePreset _selectedPreset = DateRangePreset.last7Days;
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) {
    final dateRange =
        _selectedPreset == DateRangePreset.custom && _customRange != null
            ? _customRange!
            : _selectedPreset.getRange();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh analytics data
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Selector
            _buildDateRangeSelector(),

            const SizedBox(height: 24),

            // Summary Cards
            _buildSummaryCards(),

            const SizedBox(height: 24),

            // Charts
            _buildCharts(dateRange),

            const SizedBox(height: 24),

            // Insights
            _buildInsights(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DateRangePreset.values.map((preset) {
                final isSelected = _selectedPreset == preset;
                return ChoiceChip(
                  label: Text(preset.label),
                  selected: isSelected,
                  onSelected: (selected) async {
                    if (preset == DateRangePreset.custom) {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange:
                            _customRange ?? _selectedPreset.getRange(),
                      );
                      if (range != null) {
                        setState(() {
                          _customRange = range;
                          _selectedPreset = preset;
                        });
                      }
                    } else {
                      setState(() {
                        _selectedPreset = preset;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            if (_selectedPreset == DateRangePreset.custom &&
                _customRange != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Selected: ${_formatDate(_customRange!.start)} - ${_formatDate(_customRange!.end)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    // Mock data - replace with actual data from providers
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Movements',
          '245',
          Icons.swap_horiz,
          Colors.blue,
          '+12%',
        ),
        _buildSummaryCard(
          'Inbound',
          '156',
          Icons.arrow_downward,
          Colors.green,
          '+8%',
        ),
        _buildSummaryCard(
          'Outbound',
          '89',
          Icons.arrow_upward,
          Colors.orange,
          '+4%',
        ),
        _buildSummaryCard(
          'Net Change',
          '+67',
          Icons.trending_up,
          Colors.purple,
          'Positive',
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String? trend,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                if (trend != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts(DateTimeRange dateRange) {
    // Mock data - replace with actual analytics data
    final trendData = _generateMockTrendData();
    final movementData = _generateMockMovementData();

    return Column(
      children: [
        StockTrendChart(data: trendData),
        const SizedBox(height: 16),
        MovementBarChart(data: movementData),
      ],
    );
  }

  Widget _buildInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              '📈 Stock activity increased by 12% compared to last period',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              '⚠️ 5 items are approaching reorder level',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              '✅ Inbound rate is higher than outbound - healthy stock growth',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Mock data generators - replace with real data
  List<TrendData> _generateMockTrendData() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return TrendData(
        date: now.subtract(Duration(days: 6 - index)),
        value: 100 + (index * 10).toDouble() + (index % 2 == 0 ? 5 : -5),
      );
    });
  }

  List<MovementData> _generateMockMovementData() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return MovementData(
        date: now.subtract(Duration(days: 6 - index)),
        inbound: 20 + (index * 5),
        outbound: 15 + (index * 3),
      );
    });
  }
}
