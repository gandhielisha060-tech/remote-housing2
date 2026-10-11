import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/property.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_providers.dart';
import '../../widgets/app_bar_controls.dart';
import '../../widgets/metric_tile.dart';
import '../../widgets/property_card.dart';
import '../../widgets/soc_widgets.dart';

class LandlordDashboardScreen extends ConsumerWidget {
  const LandlordDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final properties = ref.watch(landlordPropertiesProvider(user?.id ?? ''));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Landlord workspace'),
        actions: [
          FilledButton.icon(
            onPressed: () => context.go('/landlord/add-property'),
            icon: const Icon(Icons.add_home_work_outlined),
            label: const Text('Add property'),
          ),
          const SizedBox(width: 6),
          const AppBarControls(),
        ],
      ),
      body: properties.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Could not load listings: $error')),
        data: (items) {
          final approved = items
              .where((item) => item.status == PropertyStatus.approved)
              .length;
          final pending = items
              .where((item) => item.status == PropertyStatus.pending)
              .length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              GlassPanel(
                accent: scheme.secondary,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor: scheme.secondary.withValues(alpha: 0.16),
                      child: Icon(
                        Icons.apartment_outlined,
                        color: scheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Operations overview',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user?.name ?? 'Landlord'} - keep your listing signals current.',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const StatusPill(
                      label: 'Owner verified',
                      tone: StatusTone.secure,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 760;
                  return GridView.count(
                    crossAxisCount: compact ? 1 : 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: compact ? 5.2 : 2.7,
                    children: [
                      MetricTile(
                        icon: Icons.home_work_outlined,
                        label: 'Total listings',
                        value: '${items.length}',
                        accent: MetricAccent.teal,
                      ),
                      MetricTile(
                        icon: Icons.verified_outlined,
                        label: 'Approved and visible',
                        value: '$approved',
                        accent: MetricAccent.green,
                      ),
                      MetricTile(
                        icon: Icons.pending_actions_outlined,
                        label: 'Awaiting review',
                        value: '$pending',
                        accent: MetricAccent.orange,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              SectionTitle(
                title: 'Your listing inventory',
                subtitle: 'Moderated homes appear to students after approval.',
                action: QuickAction(
                  icon: Icons.add,
                  label: 'New listing',
                  onPressed: () => context.go('/landlord/add-property'),
                ),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const GlassPanel(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No listings yet. Add your first home to begin.',
                      ),
                    ),
                  ),
                )
              else
                for (final property in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: PropertyCard(
                      property: property,
                      onOpen: () => context.go('/properties/${property.id}'),
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Listing actions',
                        onSelected: (action) async {
                          if (action != 'delete') return;
                          await ref
                              .read(propertyRepositoryProvider)
                              .delete(property.id, user?.id ?? '');
                          if (user != null) {
                            ref.invalidate(landlordPropertiesProvider(user.id));
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Listing deleted')),
                            );
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete listing'),
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
