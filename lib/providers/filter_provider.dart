import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/filter_model.dart';
import 'theme_provider.dart';

/// Filter state notifier
class FilterNotifier extends StateNotifier<ItemFilter> {
  final SharedPreferences _prefs;
  static const String _filterKey = 'saved_filters';
  static const String _searchHistoryKey = 'search_history';

  FilterNotifier(this._prefs) : super(const ItemFilter()) {
    _loadSavedFilter();
  }

  /// Load saved filter from preferences
  void _loadSavedFilter() {
    final savedFilter = _prefs.getString(_filterKey);
    if (savedFilter != null) {
      try {
        final map = json.decode(savedFilter) as Map<String, dynamic>;
        state = ItemFilter.fromMap(map);
      } catch (e) {
        // Ignore error, use default filter
      }
    }
  }

  /// Save current filter
  Future<void> _saveFilter() async {
    await _prefs.setString(_filterKey, json.encode(state.toMap()));
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    if (query.isNotEmpty) {
      _addToSearchHistory(query);
    }
  }

  /// Set date range
  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
    _saveFilter();
  }

  /// Set stock level filter
  void setStockLevel(StockLevelFilter? level) {
    state = state.copyWith(stockLevel: level);
    _saveFilter();
  }

  /// Set min/max stock
  void setStockRange(double? min, double? max) {
    state = state.copyWith(minStock: min, maxStock: max);
    _saveFilter();
  }

  /// Set categories
  void setCategories(List<String>? categories) {
    state = state.copyWith(categories: categories);
    _saveFilter();
  }

  /// Set sorting
  void setSorting(String? sortBy, bool ascending) {
    state = state.copyWith(sortBy: sortBy, sortAscending: ascending);
    _saveFilter();
  }

  /// Clear all filters
  void clearFilters() {
    state = const ItemFilter();
    _prefs.remove(_filterKey);
  }

  /// Apply complete filter
  void applyFilter(ItemFilter filter) {
    state = filter;
    _saveFilter();
  }

  // Search History Management
  List<String> getSearchHistory() {
    final history = _prefs.getStringList(_searchHistoryKey) ?? [];
    return history;
  }

  void _addToSearchHistory(String query) {
    final history = getSearchHistory();

    // Remove if already exists
    history.remove(query);

    // Add to top
    history.insert(0, query);

    // Keep only last 10
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    _prefs.setStringList(_searchHistoryKey, history);
  }

  void clearSearchHistory() {
    _prefs.remove(_searchHistoryKey);
  }

  void removeFromHistory(String query) {
    final history = getSearchHistory();
    history.remove(query);
    _prefs.setStringList(_searchHistoryKey, history);
  }
}

/// Filter provider
final filterProvider = StateNotifierProvider<FilterNotifier, ItemFilter>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return FilterNotifier(prefs);
  },
);

/// Search history provider
final searchHistoryProvider = Provider<List<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getStringList('search_history') ?? [];
});
