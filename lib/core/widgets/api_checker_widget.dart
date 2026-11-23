import 'package:flutter/material.dart';

class ApiCheckerWidget extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final VoidCallback onPressed;

  const ApiCheckerWidget({
    super.key,
    required this.child,
    required this.isActive,
    required this.onPressed,
  });

  @override
  State<ApiCheckerWidget> createState() => _ApiCheckerWidgetState();
}

class _ApiCheckerWidgetState extends State<ApiCheckerWidget> {
  double posX = 0;
  double posY = 100;

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

    return LayoutBuilder(
      builder: (context, constraints) {
        const buttonSize = 56.0;
        final maxX = (constraints.maxWidth - buttonSize).clamp(
          0.0,
          double.infinity,
        );
        final maxY = (constraints.maxHeight - buttonSize).clamp(
          0.0,
          double.infinity,
        );

        return Stack(
          children: [
            widget.child,
            Positioned(
              left: posX.clamp(0.0, maxX),
              top: posY.clamp(0.0, maxY),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    posY += details.delta.dy;
                    posY = posY.clamp(0.0, maxY);
                    posX = (posX + details.delta.dx).clamp(0.0, maxX);
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    final middle = constraints.maxWidth / 2;
                    if (posX < middle) {
                      posX = 0;
                    } else {
                      posX = maxX;
                    }
                  });
                },
                child: IconButton.outlined(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: widget.onPressed,
                  icon: const Icon(
                    Icons.bug_report,
                    color: Colors.red,
                    size: 35,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
