import 'package:flutter/material.dart';

/// Custom "Dashboard" header with orange (top) and green (bottom) color effect
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const text = 'Dashboard';
    final style = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 28,
    );

    return Stack(
      children: [
        // Clipped text (bottom half) — Green color
        ClipRect(
          child: Align(
            alignment: Alignment.bottomLeft,
            heightFactor: 0.5,
            child: Text(text, style: style?.copyWith(color: Colors.green[600])),
          ),
        ),
        // Clipped text (top half) — Orange color
        ClipRect(
          child: Align(
            alignment: Alignment.topLeft,
            heightFactor: 0.5,
            child: Text(
              text,
              style: style?.copyWith(color: Colors.orange[600]),
            ),
          ),
        ),
      ],
    );
  }
}
