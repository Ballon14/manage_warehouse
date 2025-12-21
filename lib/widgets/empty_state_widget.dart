import 'package:flutter/material.dart';

/// A reusable empty state widget for displaying when no data is available.
/// 
/// This widget follows Flutter best practices:
/// - Const constructor for optimal performance
/// - Semantic labels for accessibility
/// - Customizable appearance
/// - Clear visual hierarchy
/// 
/// Example usage:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.inventory_2_outlined,
///   title: 'No Items',
///   message: 'Start by adding your first item',
///   onAction: () => navigateToAddItem(),
///   actionLabel: 'Add Item',
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// The icon to display at the top
  final IconData icon;
  
  /// The main title text
  final String title;
  
  /// The descriptive message text
  final String message;
  
  /// Optional callback when action button is pressed
  final VoidCallback? onAction;
  
  /// Optional label for the action button (defaults to 'Tambah')
  final String? actionLabel;
  
  /// Optional custom icon color (defaults to grey)
  final Color? iconColor;
  
  /// Optional icon for the action button (defaults to Icons.add)
  final IconData? actionIcon;
  
  /// Optional semantic label for accessibility
  final String? semanticLabel;

  /// Creates an empty state widget.
  /// 
  /// [icon], [title], and [message] are required.
  /// [onAction] and [actionLabel] are optional for displaying an action button.
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onAction,
    this.actionLabel,
    this.iconColor,
    this.actionIcon,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Semantics(
      label: semanticLabel ?? 
             'Empty state: $title. $message${onAction != null ? ". Tap to ${actionLabel ?? "add"}." : ""}',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Icon(
                icon,
                size: 80,
                color: iconColor ?? Colors.grey.shade300,
                semanticLabel: 'Empty state icon',
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Message
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              // Optional action button
              if (onAction != null) ...[
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon ?? Icons.add),
                  label: Text(actionLabel ?? 'Tambah'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A specialized empty state widget for search results.
/// 
/// Example:
/// ```dart
/// EmptySearchState(
///   query: searchQuery,
///   onClearSearch: () => clearSearch(),
/// )
/// ```
class EmptySearchState extends StatelessWidget {
  /// The search query that returned no results
  final String query;
  
  /// Callback to clear the search
  final VoidCallback? onClearSearch;

  const EmptySearchState({
    super.key,
    required this.query,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Tidak Ada Hasil',
      message: 'Tidak ditemukan hasil untuk "$query"',
      onAction: onClearSearch,
      actionLabel: 'Hapus Pencarian',
      actionIcon: Icons.clear,
      semanticLabel: 'No search results found for $query',
    );
  }
}

/// A specialized empty state widget for errors.
/// 
/// Example:
/// ```dart
/// ErrorStateWidget(
///   errorMessage: 'Failed to load data',
///   onRetry: () => retryLoading(),
/// )
/// ```
class ErrorStateWidget extends StatelessWidget {
  /// The error message to display
  final String errorMessage;
  
  /// Optional callback to retry the failed operation
  final VoidCallback? onRetry;
  
  /// Optional custom title (defaults to 'Terjadi Kesalahan')
  final String? title;

  const ErrorStateWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      iconColor: Colors.red.shade300,
      title: title ?? 'Terjadi Kesalahan',
      message: errorMessage,
      onAction: onRetry,
      actionLabel: 'Coba Lagi',
      actionIcon: Icons.refresh,
      semanticLabel: 'Error: $errorMessage',
    );
  }
}
