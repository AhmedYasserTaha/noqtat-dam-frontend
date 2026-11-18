import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/app_bottom_nav.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;
  static const paths = ['/', '/map', '/requests', '/profile'];

  @override
  Widget build(BuildContext context) {
    final index = paths.indexOf(location);
    return Scaffold(
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: AppBottomNav(
        selected: AppNavDestination.values[index < 0 ? 0 : index],
        onSelected: (destination) => context.go(paths[destination.index]),
        onCreate: () => context.push('/blood-request'),
      ),
    );
  }
}

class PendingTabPage extends StatelessWidget {
  const PendingTabPage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context)!.placeholder),
      ],
    ),
  );
}
