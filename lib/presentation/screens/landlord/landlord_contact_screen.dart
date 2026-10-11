import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/app_bar_controls.dart';
import '../../widgets/soc_widgets.dart';

class LandlordContactScreen extends ConsumerWidget {
  const LandlordContactScreen({required this.landlordId, super.key});

  final String landlordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref.watch(authRepositoryProvider).findById(landlordId);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Landlord profile'),
        actions: const [AppBarControls()],
      ),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Landlord details unavailable.'));
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: GlassPanel(
                  accent: scheme.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: scheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            child: Icon(
                              Icons.apartment_outlined,
                              color: scheme.primary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 6),
                                const StatusPill(
                                  label: 'Verified housing partner',
                                  tone: StatusTone.secure,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      const Divider(),
                      const SizedBox(height: 14),
                      _ContactRow(
                        icon: Icons.mail_outline,
                        label: 'Email address',
                        value: user.email,
                      ),
                      const SizedBox(height: 16),
                      _ContactRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone number',
                        value: user.phone ?? 'Not provided',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Contact guidance',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ask for a viewing, confirm the advertised rent, and keep payment discussions on the platform until the property has been verified.',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: scheme.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 3),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}
