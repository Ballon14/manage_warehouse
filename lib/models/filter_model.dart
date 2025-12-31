import 'package:flutter/material.dart';

/// Filter model for items
class ItemFilter {
  final String? searchQuery;
  final DateTimeRange? dateRange;
  final StockLevelFilter? stockLevel;
  final List<String>? categories;
  final double? minStock;
  final double? maxStock;
  final String? sortBy;
  final bool sortAscending;

  const ItemFilter({
    this.searchQuery,
    this.dateRange,
    this.stockLevel,
    this.categories,
    this.minStock,
    this.maxStock,
    this.sortBy,
    this.sortAscending = true,
  });

  ItemFilter copyWith({
    String? searchQuery,
    DateTimeRange? dateRange,
    StockLevelFilter? stockLevel,
    List<String>? categories,
    double? minStock,
    double? maxStock,
    String? sortBy,
    bool? sortAscending,
  }) {
    return ItemFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      dateRange: dateRange ?? this.dateRange,
      stockLevel: stockLevel ?? this.stockLevel,
      categories: categories ?? this.categories,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// Check if any filter is active
  bool get hasActiveFilters =>
      searchQuery != null && searchQuery!.isNotEmpty ||
      dateRange != null ||
      stockLevel != null ||
      categories != null && categories!.isNotEmpty ||
      minStock != null ||
      maxStock != null;

  /// Clear all filters
  ItemFilter clear() {
    return const ItemFilter();
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'searchQuery': searchQuery,
      'dateRangeStart': dateRange?.start.toIso8601String(),
      'dateRangeEnd': dateRange?.end.toIso8601String(),
      'stockLevel': stockLevel?.name,
      'categories': categories,
      'minStock': minStock,
      'maxStock': maxStock,
      'sortBy': sortBy,
      'sortAscending': sortAscending,
    };
  }

  /// Create from map
  factory ItemFilter.fromMap(Map<String, dynamic> map) {
    return ItemFilter(
      searchQuery: map['searchQuery'],
      dateRange: map['dateRangeStart'] != null && map['dateRangeEnd'] != null
          ? DateTimeRange(
              start: DateTime.parse(map['dateRangeStart']),
              end: DateTime.parse(map['dateRangeEnd']),
            )
          : null,
      stockLevel: map['stockLevel'] != null
          ? StockLevelFilter.values
              .firstWhere((e) => e.name == map['stockLevel'])
          : null,
      categories: map['categories'] != null
          ? List<String>.from(map['categories'])
          : null,
      minStock: map['minStock']?.toDouble(),
      maxStock: map['maxStock']?.toDouble(),
      sortBy: map['sortBy'],
      sortAscending: map['sortAscending'] ?? true,
    );
  }
}

/// Stock level filter options
enum StockLevelFilter {
  all,
  inStock,
  lowStock,
  outOfStock,
}

extension StockLevelFilterExtension on StockLevelFilter {
  String get displayName {
    switch (this) {
      case StockLevelFilter.all:
        return 'All Items';
      case StockLevelFilter.inStock:
        return 'In Stock';
      case StockLevelFilter.lowStock:
        return 'Low Stock';
      case StockLevelFilter.outOfStock:
        return 'Out of Stock';
    }
  }

  IconData get icon {
    switch (this) {
      case StockLevelFilter.all:
        return Icons.inventory_2;
      case StockLevelFilter.inStock:
        return Icons.check_circle;
      case StockLevelFilter.lowStock:
        return Icons.warning_amber;
      case StockLevelFilter.outOfStock:
        return Icons.cancel;
    }
  }

  Color get color {
    switch (this) {
      case StockLevelFilter.all:
        return Colors.blue;
      case StockLevelFilter.inStock:
        return Colors.green;
      case StockLevelFilter.lowStock:
        return Colors.orange;
      case StockLevelFilter.outOfStock:
        return Colors.red;
    }
  }
}
