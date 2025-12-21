import 'package:flutter/material.dart';

/// A shimmer loading skeleton widget for better loading UX.
/// 
/// This widget follows Flutter best practices:
/// - Smooth gradient animation
/// - Multiple preset constructors
/// - Customizable colors and dimensions
/// - Proper widget lifecycle management
/// - Accessibility support
/// 
/// Example usage:
/// ```dart
/// // Basic skeleton
/// LoadingSkeleton(width: 200, height: 20)
///
/// // Card skeleton
/// LoadingSkeleton.card(height: 120)
///
/// // Circular skeleton (avatar)
/// LoadingSkeleton.circular(size: 48)
///
/// // List tile skeleton
/// LoadingSkeleton.listTile()
/// ```
class LoadingSkeleton extends StatefulWidget {
  /// Width of the skeleton (null for flexible width)
  final double? width;
  
  /// Height of the skeleton
  final double height;
  
  /// Border radius for rounded corners
  final BorderRadius? borderRadius;
  
  /// Base color for the skeleton
  final Color? baseColor;
  
  /// Highlight color for the shimmer effect
  final Color? highlightColor;
  
  /// Semantic label for accessibility
  final String? semanticLabel;

  /// Creates a basic loading skeleton.
  const LoadingSkeleton({
    super.key,
    this.width,
    this.height = 20,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.semanticLabel,
  });

  /// Creates a skeleton for a card with rounded corners.
  const LoadingSkeleton.card({
    super.key,
    this.width,
    this.height = 120,
  })  : borderRadius = const BorderRadius.all(Radius.circular(16)),
        baseColor = null,
        highlightColor = null,
        semanticLabel = 'Loading card';

  /// Creates a circular skeleton (e.g., for avatars).
  const LoadingSkeleton.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = null,
        baseColor = null,
        highlightColor = null,
        semanticLabel = 'Loading avatar';

  /// Creates a skeleton for a list tile.
  const LoadingSkeleton.listTile({
    super.key,
  })  : width = double.infinity,
        height = 80,
        borderRadius = const BorderRadius.all(Radius.circular(12)),
        baseColor = null,
        highlightColor = null,
        semanticLabel = 'Loading list item';

  /// Creates a skeleton for text (single line).
  const LoadingSkeleton.text({
    super.key,
    this.width,
  })  : height = 16,
        borderRadius = const BorderRadius.all(Radius.circular(4)),
        baseColor = null,
        highlightColor = null,
        semanticLabel = 'Loading text';

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey.shade300;
    final highlightColor = widget.highlightColor ?? Colors.grey.shade100;
    
    BorderRadius? borderRadius = widget.borderRadius;
    if (borderRadius == null && widget.width == widget.height) {
      // Circular skeleton
      borderRadius = BorderRadius.circular(widget.height / 2);
    } else {
      borderRadius ??= BorderRadius.circular(8);
    }

    return Semantics(
      label: widget.semanticLabel ?? 'Loading content',
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  baseColor,
                  highlightColor,
                  baseColor,
                ],
                stops: [
                  0.0,
                  _animation.value.clamp(0.0, 1.0),
                  1.0,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A list of loading skeletons for list views.
/// 
/// Example:
/// ```dart
/// SkeletonList(
///   itemCount: 10,
///   itemHeight: 80,
/// )
/// ```
class SkeletonList extends StatelessWidget {
  /// Number of skeleton items to display
  final int itemCount;
  
  /// Height of each skeleton item
  final double itemHeight;
  
  /// Padding around the list
  final EdgeInsets? padding;
  
  /// Spacing between items
  final double spacing;
  
  /// Border radius for items
  final BorderRadius? borderRadius;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
    this.spacing = 12,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading list with $itemCount items',
      child: ListView.builder(
        padding: padding ?? const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: LoadingSkeleton(
              width: double.infinity,
              height: itemHeight,
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}

/// A card-style loading skeleton with avatar and text lines.
/// 
/// Example:
/// ```dart
/// SkeletonCard()
/// ```
class SkeletonCard extends StatelessWidget {
  /// Optional margin around the card
  final EdgeInsets? margin;

  const SkeletonCard({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading card content',
      child: Card(
        margin: margin ?? const EdgeInsets.all(16),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar and two text lines
              Row(
                children: [
                  LoadingSkeleton.circular(size: 48),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LoadingSkeleton(width: 150, height: 20),
                        SizedBox(height: 8),
                        LoadingSkeleton(width: 100, height: 16),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Body with three text lines
              LoadingSkeleton(width: double.infinity, height: 16),
              SizedBox(height: 8),
              LoadingSkeleton(width: double.infinity, height: 16),
              SizedBox(height: 8),
              LoadingSkeleton(width: 200, height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// A grid of loading skeleton cards.
/// 
/// Example:
/// ```dart
/// SkeletonGrid(
///   crossAxisCount: 2,
///   itemCount: 6,
/// )
/// ```
class SkeletonGrid extends StatelessWidget {
  /// Number of items per row
  final int crossAxisCount;
  
  /// Total number of items
  final int itemCount;
  
  /// Aspect ratio of each item
  final double childAspectRatio;
  
  /// Padding around the grid
  final EdgeInsets? padding;
  
  /// Spacing between items
  final double spacing;

  const SkeletonGrid({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.childAspectRatio = 1.0,
    this.padding,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading grid with $itemCount items',
      child: GridView.builder(
        padding: padding ?? const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const LoadingSkeleton.card();
        },
      ),
    );
  }
}

/// A profile skeleton with avatar and text lines.
/// 
/// Example:
/// ```dart
/// SkeletonProfile()
/// ```
class SkeletonProfile extends StatelessWidget {
  const SkeletonProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading profile',
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            LoadingSkeleton.circular(size: 80),
            SizedBox(height: 16),
            
            // Name
            LoadingSkeleton(width: 150, height: 24),
            SizedBox(height: 8),
            
            // Email/subtitle
            LoadingSkeleton(width: 200, height: 16),
            SizedBox(height: 24),
            
            // Info rows
            LoadingSkeleton(width: double.infinity, height: 20),
            SizedBox(height: 12),
            LoadingSkeleton(width: double.infinity, height: 20),
            SizedBox(height: 12),
            LoadingSkeleton(width: double.infinity, height: 20),
          ],
        ),
      ),
    );
  }
}
