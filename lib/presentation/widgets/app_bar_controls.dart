import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import 'theme_mode_toggle.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      icon: const Icon(Icons.arrow_back),
    );
  }
}

class AppBarControls extends ConsumerWidget {
  const AppBarControls({this.showLogout = true, super.key});

  final bool showLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ThemeModeToggle(),
        if (showLogout)
          IconButton(
            tooltip: 'Logout',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}
