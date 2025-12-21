import 'package:flutter/material.dart';

/// A reusable info chip widget for displaying status or category.
/// 
/// This widget provides:
/// - Consistent styling
/// - Multiple color variants
/// - Optional delete callback
/// - Accessibility support
/// 
/// Example usage:
/// ```dart
/// InfoChip(
///   label: 'Active',
///   variant: ChipVariant.success,
/// )
/// ```
class InfoChip extends StatelessWidget {
  /// The chip label text
  final String label;
  
  /// Chip color variant
  final ChipVariant variant;
  
  /// Optional icon
  final IconData? icon;
  
  /// Optional delete callback
  final VoidCallback? onDeleted;
  
  /// Optional tap callback
  final VoidCallback? onTap;
  
  /// Whether to show bold text
  final bool bold;

  const InfoChip({
    super.key,
    required this.label,
    this.variant = ChipVariant.neutral,
    this.icon,
    this.onDeleted,
    this.onTap,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(context);
    
    final chip = Chip(
      label: Text(
        label,
        style: TextStyle(
          color: colors.textColor,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      avatar: icon != null
          ? Icon(
              icon,
              size: 16,
              color: colors.textColor,
            )
          : null,
      backgroundColor: colors.backgroundColor,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onDeleted: onDeleted,
      deleteIconColor: colors.textColor,
    );
    
    if (onTap != null) {
      return Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: chip,
        ),
      );
    }
    
    return Semantics(
      label: '$label chip',
      child: chip,
    );
  }
  
  _ChipColors _getColors(BuildContext context) {
    switch (variant) {
      case ChipVariant.success:
        return _ChipColors(
          backgroundColor: Colors.green.shade100,
          textColor: Colors.green.shade800,
        );
      case ChipVariant.error:
        return _ChipColors(
          backgroundColor: Colors.red.shade100,
          textColor: Colors.red.shade800,
        );
      case ChipVariant.warning:
        return _ChipColors(
          backgroundColor: Colors.orange.shade100,
          textColor: Colors.orange.shade800,
        );
      case ChipVariant.info:
        return _ChipColors(
          backgroundColor: Colors.blue.shade100,
          textColor: Colors.blue.shade800,
        );
      case ChipVariant.neutral:
      default:
        return _ChipColors(
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.grey.shade800,
        );
    }
  }
}

/// Color variant for chips
enum ChipVariant {
  /// Neutral/default color
  neutral,
  
  /// Success/positive color (green)
  success,
  
  /// Error/negative color (red)
  error,
  
  /// Warning color (orange)
  warning,
  
  /// Info color (blue)
  info,
}

class _ChipColors {
  final Color backgroundColor;
  final Color textColor;

  _ChipColors({
    required this.backgroundColor,
    required this.textColor,
  });
}

/// A specialized status chip with predefined states.
/// 
/// Example:
/// ```dart
/// StatusChip(status: ItemStatus.active)
/// ```
class StatusChip extends StatelessWidget {
  /// The status to display
  final String status;
  
  /// Whether the status is active/positive
  final bool isActive;

  const StatusChip({
    super.key,
    required this.status,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return InfoChip(
      label: status,
      variant: isActive ? ChipVariant.success : ChipVariant.neutral,
      icon: isActive ? Icons.check_circle : Icons.circle_outlined,
    );
  }
}

/// A chip for displaying stock level status.
/// 
/// Example:
/// ```dart
/// StockLevelChip(
///   quantity: 50,
///   reorderLevel: 20,
/// )
/// ```
class StockLevelChip extends StatelessWidget {
  /// Current stock quantity
  final double quantity;
  
  /// Reorder level threshold
  final double reorderLevel;

  const StockLevelChip({
    super.key,
    required this.quantity,
    required this.reorderLevel,
  });

  @override
  Widget build(BuildContext context) {
    final ChipVariant variant;
    final IconData icon;
    
    if (quantity <= 0) {
      variant = ChipVariant.error;
      icon = Icons.close;
    } else if (quantity <= reorderLevel) {
      variant = ChipVariant.warning;
      icon = Icons.warning;
    } else {
      variant = ChipVariant.success;
      icon = Icons.check;
    }
    
    return InfoChip(
      label: 'Stok: ${quantity.toInt()}',
      variant: variant,
      icon: icon,
      bold: quantity <= reorderLevel,
    );
  }
}
