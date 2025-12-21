import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manage_your_logistic/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('should display icon, title, and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'Add your first item',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No Items'), findsOneWidget);
      expect(find.text('Add your first item'), findsOneWidget);
    });

    testWidgets('should display action button when provided', (tester) async {
      var buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'Add your first item',
              onAction: () => buttonPressed = true,
              actionLabel: 'Add Item',
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
      
      await tester.tap(find.text('Add Item'));
      expect(buttonPressed, true);
    });

    testWidgets('should not display action button when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'No Items',
              message: 'Add your first item',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
