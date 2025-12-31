import 'package:flutter/material.dart';

/// Trend indicator widget showing value change
class TrendIndicator extends StatelessWidget {
  final double value;
  final double? previousValue;
  final bool showPercentage;
  final Color? positiveColor;
  final Color? negativeColor;

  const TrendIndicator({
    super.key,
    required this.value,
    this.previousValue,
    this.showPercentage = true,
    this.positiveColor,
    this.negativeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (previousValue == null || previousValue == 0) {
      return const SizedBox.shrink();
    }

    final change = value - previousValue!;
    final percentChange = (change / previousValue!) * 100;
    final isPositive = change > 0;
    final isNeutral = change == 0;

    if (isNeutral) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.remove,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            '0%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }

    final color = isPositive
        ? (positiveColor ?? Colors.green[600])
        : (negativeColor ?? Colors.red[600]);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0, end: 1),
      builder: (context, animation, child) {
        return Opacity(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, (1 - animation) * 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  showPercentage
                      ? '${percentChange.abs().toStringAsFixed(1)}%'
                      : change.abs().toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Simple trend indicator with just icon
class SimpleTrendIndicator extends StatelessWidget {
  final bool isUp;
  final Color? color;

  const SimpleTrendIndicator({
    super.key,
    required this.isUp,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor =
        color ?? (isUp ? Colors.green[600] : Colors.red[600])!;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0, end: 1),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Icon(
            isUp ? Icons.trending_up : Icons.trending_down,
            size: 20,
            color: indicatorColor,
          ),
        );
      },
    );
  }
}
