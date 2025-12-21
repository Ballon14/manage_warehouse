import 'package:flutter/material.dart';

/// A reusable custom button widget with consistent styling.
/// 
/// This widget provides:
/// - Multiple button styles (primary, secondary, outline, text)
/// - Loading state support
/// - Icon support
/// - Accessibility
/// 
/// Example usage:
/// ```dart
/// CustomButton(
///   label: 'Save',
///   onPressed: () => save(),
///   icon: Icons.save,
///   isLoading: isSaving,
/// )
/// ```
class CustomButton extends StatelessWidget {
  /// The button label text
  final String label;
  
  /// Callback when button is pressed
  final VoidCallback? onPressed;
  
  /// Optional icon
  final IconData? icon;
  
  /// Whether the button is in loading state
  final bool isLoading;
  
  /// Button style variant
  final ButtonVariant variant;
  
  /// Button size
  final ButtonSize size;
  
  /// Whether button should expand to fill width
  final bool expand;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.expand = false,
  });

  /// Create a loading button
  const CustomButton.loading({
    super.key,
    required this.label,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.expand = false,
  })  : onPressed = null,
        isLoading = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get dimensions based on size
    final EdgeInsets padding;
    final double fontSize;
    switch (size) {
      case ButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        fontSize = 14;
        break;
      case ButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
        fontSize = 18;
        break;
      case ButtonSize.medium:
      default:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
        fontSize = 16;
    }
    
    final buttonStyle = _getButtonStyle(theme, padding);
    
    Widget button;
    
    // Build button based on variant
    switch (variant) {
      case ButtonVariant.primary:
        button = icon != null
            ? ElevatedButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: _buildIcon(),
                label: _buildLabel(fontSize),
                style: buttonStyle,
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: buttonStyle,
                child: _buildLabel(fontSize),
              );
        break;
        
      case ButtonVariant.secondary:
        button = icon != null
            ? FilledButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: _buildIcon(),
                label: _buildLabel(fontSize),
                style: buttonStyle,
              )
            : FilledButton(
                onPressed: isLoading ? null : onPressed,
                style: buttonStyle,
                child: _buildLabel(fontSize),
              );
        break;
        
      case ButtonVariant.outline:
        button = icon != null
            ? OutlinedButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: _buildIcon(),
                label: _buildLabel(fontSize),
                style: buttonStyle,
              )
            : OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: buttonStyle,
                child: _buildLabel(fontSize),
              );
        break;
        
      case ButtonVariant.text:
        button = icon != null
            ? TextButton.icon(
                onPressed: isLoading ? null : onPressed,
                icon: _buildIcon(),
                label: _buildLabel(fontSize),
                style: buttonStyle,
              )
            : TextButton(
                onPressed: isLoading ? null : onPressed,
                style: buttonStyle,
                child: _buildLabel(fontSize),
              );
        break;
    }
    
    if (expand) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return Semantics(
      button: true,
      enabled: !isLoading && onPressed != null,
      label: isLoading ? 'Loading: $label' : label,
      child: button,
    );
  }
  
  Widget _buildIcon() {
    if (isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }
    
    return Icon(icon);
  }
  
  Widget _buildLabel(double fontSize) {
    return Text(
      label,
      style: TextStyle(fontSize: fontSize),
    );
  }
  
  ButtonStyle _getButtonStyle(ThemeData theme, EdgeInsets padding) {
    return ButtonStyle(
      padding: WidgetStateProperty.all(padding),
      minimumSize: expand
          ? WidgetStateProperty.all(const Size(double.infinity, 0))
          : null,
    );
  }
}

/// Button style variants
enum ButtonVariant {
  /// Filled button with primary color
  primary,
  
  /// Filled button with secondary color
  secondary,
  
  /// Outlined button
  outline,
  
  /// Text-only button
  text,
}

/// Button size presets
enum ButtonSize {
  /// Small button
  small,
  
  /// Medium button (default)
  medium,
  
  /// Large button
  large,
}

/// A specialized icon button with consistent styling.
/// 
/// Example:
/// ```dart
/// CustomIconButton(
///   icon: Icons.edit,
///   onPressed: () => edit(),
///   tooltip: 'Edit',
/// )
/// ```
class CustomIconButton extends StatelessWidget {
  /// The icon to display
  final IconData icon;
  
  /// Callback when button is pressed
  final VoidCallback? onPressed;
  
  /// Optional tooltip
  final String? tooltip;
  
  /// Optional background color
  final Color? backgroundColor;
  
  /// Optional icon color
  final Color? iconColor;
  
  /// Button size
  final double size;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size * 0.5,
      color: iconColor,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: Size(size, size),
        padding: EdgeInsets.zero,
      ),
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}
