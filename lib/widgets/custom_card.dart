import 'package:flutter/material.dart';

/// A reusable custom card widget with consistent styling.
/// 
/// This widget provides:
/// - Consistent elevation and shadow
/// - Tap feedback with ripple effect
/// - Optional leading/trailing widgets
/// - Accessibility support
/// 
/// Example usage:
/// ```dart
/// CustomCard(
///   title: 'Item Name',
///   subtitle: 'SKU: ABC123',
///   leading: Icon(Icons.inventory),
///   onTap: () => viewDetails(),
/// )
/// ```
class CustomCard extends StatelessWidget {
  /// The main title text
  final String title;
  
  /// Optional subtitle text
  final String? subtitle;
  
  /// Optional leading widget (e.g., icon or avatar)
  final Widget? leading;
  
  /// Optional trailing widget (e.g., icon or button)
  final Widget? trailing;
  
  /// Callback when card is tapped
  final VoidCallback? onTap;
  
  /// Optional custom padding
  final EdgeInsets? padding;
  
  /// Optional custom margin
  final EdgeInsets? margin;
  
  /// Optional elevation (defaults to 2)
  final double? elevation;
  
  /// Optional semantic label for accessibility
  final String? semanticLabel;

  const CustomCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final card = Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: elevation ?? 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Row(
            children: [
              // Leading widget
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16),
              ],
              
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Trailing widget
              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
    
    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: card,
      );
    }
    
    return card;
  }
}

/// A stat card for displaying key metrics.
/// 
/// Example:
/// ```dart
/// StatCard(
///   title: 'Total Items',
///   value: '150',
///   icon: Icons.inventory,
///   color: Colors.blue,
/// )
/// ```
class StatCard extends StatelessWidget {
  /// The metric title
  final String title;
  
  /// The metric value
  final String value;
  
  /// Optional icon
  final IconData? icon;
  
  /// Optional background color
  final Color? color;
  
  /// Optional change indicator (e.g., '+10%')
  final String? changeIndicator;
  
  /// Whether the change is positive
  final bool? isPositive;
  
  /// Callback when card is tapped
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.changeIndicator,
    this.isPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;
    
    return Semantics(
      label: '$title: $value${changeIndicator != null ? ", change: $changeIndicator" : ""}',
      button: onTap != null,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  cardColor.withValues(alpha: 0.1),
                  cardColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and title
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: cardColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Value
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
                
                // Change indicator
                if (changeIndicator != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isPositive == true
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 16,
                        color: isPositive == true
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        changeIndicator!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isPositive == true
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
