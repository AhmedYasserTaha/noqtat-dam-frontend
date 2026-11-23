import 'package:damy/app.dart';
import 'package:damy/core/widgets/app_bottom_nav.dart';
import 'package:damy/features/home_feed/presentation/pages/home_feed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('UI starts at login and empty form opens home without auth', (
    tester,
  ) async {
    await tester.pumpWidget(const DamyApp());
    await tester.pumpAndSettle();
    expect(find.text('أهلاً بيك تاني'), findsOneWidget);
    expect(find.byType(HomeFeedPage), findsNothing);
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'تسجيل الدخول'),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeFeedPage), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
