import 'package:damy/app.dart';
import 'package:damy/core/widgets/app_bottom_nav.dart';
import 'package:damy/features/home_feed/presentation/pages/home_feed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('UI starts on home without backend initialization', (
    tester,
  ) async {
    await tester.pumpWidget(const DamyApp());
    await tester.pumpAndSettle();
    expect(find.byType(HomeFeedPage), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
    expect(tester.takeException(), isNull);
    final context = tester.element(find.byType(HomeFeedPage));
    GoRouter.of(context).go('/auth');
    await tester.pumpAndSettle();
    expect(find.text('أهلاً بيك تاني'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
