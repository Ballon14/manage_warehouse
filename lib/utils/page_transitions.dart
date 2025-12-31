import 'package:flutter/material.dart';

/// Custom page route with slide transition
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final AxisDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = AxisDirection.left,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case AxisDirection.up:
                begin = const Offset(0, 1);
                break;
              case AxisDirection.down:
                begin = const Offset(0, -1);
                break;
              case AxisDirection.right:
                begin = const Offset(-1, 0);
                break;
              case AxisDirection.left:
                begin = const Offset(1, 0);
                break;
            }

            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// Fade page route
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// Scale page route
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.8;
            const end = 1.0;
            const curve = Curves.easeOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return ScaleTransition(
              scale: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// Helper extension for easy navigation with animations
extension NavigationAnimation on BuildContext {
  Future<T?> slideToPage<T>(
    Widget page, {
    AxisDirection direction = AxisDirection.left,
  }) {
    return Navigator.push<T>(
      this,
      SlidePageRoute<T>(page: page, direction: direction),
    );
  }

  Future<T?> fadeToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      FadePageRoute<T>(page: page),
    );
  }

  Future<T?> scaleToPage<T>(Widget page) {
    return Navigator.push<T>(
      this,
      ScalePageRoute<T>(page: page),
    );
  }
}
