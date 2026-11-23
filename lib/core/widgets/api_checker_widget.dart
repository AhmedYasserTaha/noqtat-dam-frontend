import 'package:flutter/material.dart';

import '../network/api_checker.dart';

class ApiCheckerWidget extends StatelessWidget {
  const ApiCheckerWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!ApiChecker.isActive) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          right: 12,
          top: MediaQuery.paddingOf(context).top + 80,
          child: FloatingActionButton.small(
            heroTag: 'api-checker',
            onPressed: ApiChecker.open,
            child: const Icon(Icons.bug_report_outlined),
          ),
        ),
      ],
    );
  }
}
