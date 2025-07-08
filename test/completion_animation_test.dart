
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsubusu/models/animation_type.dart';
import 'package:tsubusu/widgets/atoms/completion_animation.dart';

void main() {
  testWidgets('CompletionAnimation renders ConfettiPainter for confetti type', (WidgetTester tester) async {
    final animation = AlwaysStoppedAnimation<double>(0.5);

    await tester.pumpWidget(
      MaterialApp(
        home: CompletionAnimation(
          animation: animation,
          animationType: AnimationType.confetti,
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

  testWidgets('CompletionAnimation renders BubblePopPainter for bubblePop type', (WidgetTester tester) async {
    final animation = AlwaysStoppedAnimation<double>(0.5);

    await tester.pumpWidget(
      MaterialApp(
        home: CompletionAnimation(
          animation: animation,
          animationType: AnimationType.bubblePop,
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
    expect(customPaint.painter, isA<BubblePopPainter>());
    final painter = customPaint.painter as BubblePopPainter;
    expect(painter.scale, 1.0);
    expect(painter.count, 8);
  });

  testWidgets('CompletionAnimation passes correct scale and count to ConfettiPainter when special', (WidgetTester tester) async {
    final animation = AlwaysStoppedAnimation<double>(0.5);

    await tester.pumpWidget(
      MaterialApp(
        home: CompletionAnimation(
          animation: animation,
          animationType: AnimationType.confetti,
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

  testWidgets('CompletionAnimation passes correct scale and count to BubblePopPainter when special', (WidgetTester tester) async {
    final animation = AlwaysStoppedAnimation<double>(0.5);

    await tester.pumpWidget(
      MaterialApp(
        home: CompletionAnimation(
          animation: animation,
          animationType: AnimationType.bubblePop,
          isSpecial: true,
        ),
      ),
    );

    final customPaintFinder = find.descendant(
      of: find.byType(CompletionAnimation),
      matching: find.byType(CustomPaint),
    );
    final customPaint = tester.widget<CustomPaint>(customPaintFinder);
    final painter = customPaint.painter as BubblePopPainter;
    expect(painter.scale, 2.0);
    expect(painter.count, 12);
  });
}
