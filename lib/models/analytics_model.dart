import 'package:flutter/material.dart';

/// Date range preset for analytics
enum DateRangePreset {
  today,
  yesterday,
  last7Days,
  last30Days,
  thisMonth,
  lastMonth,
  custom,
}

extension DateRangePresetExtension on DateRangePreset {
  String get label {
    switch (this) {
      case DateRangePreset.today:
        return 'Today';
      case DateRangePreset.yesterday:
        return 'Yesterday';
      case DateRangePreset.last7Days:
        return 'Last 7 Days';
      case DateRangePreset.last30Days:
        return 'Last 30 Days';
      case DateRangePreset.thisMonth:
        return 'This Month';
      case DateRangePreset.lastMonth:
        return 'Last Month';
      case DateRangePreset.custom:
        return 'Custom Range';
    }
  }

  DateTimeRange getRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case DateRangePreset.today:
        return DateTimeRange(
          start: today,
          end: now,
        );
      case DateRangePreset.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: yesterday,
          end: today,
        );
      case DateRangePreset.last7Days:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 7)),
          end: now,
        );
      case DateRangePreset.last30Days:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 30)),
          end: now,
        );
      case DateRangePreset.thisMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case DateRangePreset.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 0);
        return DateTimeRange(
          start: lastMonth,
          end: lastMonthEnd,
        );
      case DateRangePreset.custom:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 30)),
          end: now,
        );
    }
  }
}

/// Analytics data model
class AnalyticsData {
  final int totalItems;
  final int lowStockItems;
  final int outOfStockItems;
  final int totalInbound;
  final int totalOutbound;
  final double stockValue;
  final Map<String, int> categoryDistribution;
  final List<TrendData> stockTrend;
  final List<MovementData> dailyMovements;

  const AnalyticsData({
    required this.totalItems,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.totalInbound,
    required this.totalOutbound,
    required this.stockValue,
    required this.categoryDistribution,
    required this.stockTrend,
    required this.dailyMovements,
  });

  factory AnalyticsData.empty() {
    return const AnalyticsData(
      totalItems: 0,
      lowStockItems: 0,
      outOfStockItems: 0,
      totalInbound: 0,
      totalOutbound: 0,
      stockValue: 0,
      categoryDistribution: {},
      stockTrend: [],
      dailyMovements: [],
    );
  }
}

/// Trend data for charts
class TrendData {
  final DateTime date;
  final double value;
  final String? label;

  const TrendData({
    required this.date,
    required this.value,
    this.label,
  });
}

/// Movement data for daily statistics
class MovementData {
  final DateTime date;
  final int inbound;
  final int outbound;

  const MovementData({
    required this.date,
    required this.inbound,
    required this.outbound,
  });

  int get net => inbound - outbound;
}
