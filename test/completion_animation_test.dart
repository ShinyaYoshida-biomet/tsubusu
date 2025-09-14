
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsubusu/widgets/atoms/completion_animation.dart';

void main() {
  testWidgets('CompletionAnimation renders ConfettiPainter', (WidgetTester tester) async {
    final animation = AlwaysStoppedAnimation<double>(0.5);

    await tester.pumpWidget(
      MaterialApp(
        home: CompletionAnimation(
          animation: animation,
          isSpecial: false,
        ),
      ),
    );

    final customPaintFinder = find.descendant(
      of: find.byType(CompletionAnimation),
      matching: find.byType(CustomPaint),
    );
    expect(customPaintFinder, findsOneWidget);
    final customPaint = tester.widget<CustomPaint>(customPaintFinder);
    expect(customPaint.painter, isA<ConfettiPainter>());
    final painter = customPaint.painter as ConfettiPainter;
    expect(painter.scale, 1.0);
    expect(painter.count, 20);
  });

  testWidgets('CompletionAnimation passes correct scale and count to ConfettiPainter when special', (WidgetTester tester) async {
    final animation = AlwaysStoppedAnimation<double>(0.5);

    await tester.pumpWidget(
      MaterialApp(
        home: CompletionAnimation(
          animation: animation,
          isSpecial: true,
        ),
      ),
    );

    final customPaintFinder = find.descendant(
      of: find.byType(CompletionAnimation),
      matching: find.byType(CustomPaint),
    );
    final customPaint = tester.widget<CustomPaint>(customPaintFinder);
    final painter = customPaint.painter as ConfettiPainter;
    expect(painter.scale, 2.0);
    expect(painter.count, 35);
  });
}
