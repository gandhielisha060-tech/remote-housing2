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

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  static const _amenities = [
    'Water',
    'Electricity',
    'Internet',
    'Security',
    'Kitchen',
    'Bathroom',
    'Parking',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final properties = ref.watch(propertiesProvider);
    final filter = ref.watch(propertyFilterProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Student workspace'),
        actions: const [AppBarControls()],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(propertiesProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            GlassPanel(
              accent: scheme.primary,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: scheme.primary.withValues(alpha: 0.16),
                    child: Icon(Icons.school_outlined, color: scheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good day, ${auth.user?.name ?? 'student'}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verified homes within reach of MAU.',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const StatusPill(
                    label: 'Network secure',
                    tone: StatusTone.secure,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            properties.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) =>
                  Text('Could not load properties: $error'),
              data: (items) => Column(
                children: [
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
                            icon: Icons.apartment_outlined,
                            label: 'Approved listings',
                            value: '${items.length}',
                            accent: MetricAccent.green,
                          ),
                          const MetricTile(
                            icon: Icons.favorite_border,
                            label: 'Saved properties',
                            value: '0',
                            accent: MetricAccent.orange,
                          ),
                          const MetricTile(
                            icon: Icons.location_on_outlined,
                            label: 'Reference zone',
                            value: 'MAU gate',
                            accent: MetricAccent.teal,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  GlassPanel(
                    accent: scheme.secondary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          title: 'Find your next place',
                          subtitle:
                              'Search by location, price signal, or amenity.',
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Community, title, or address',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) =>
                              ref.read(propertyFilterProvider.notifier).state =
                                  filter.copyWith(query: value),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            DropdownButton<PropertySort>(
                              value: filter.sort,
                              items: PropertySort.values
                                  .map(
                                    (sort) => DropdownMenuItem(
                                      value: sort,
                                      child: Text(sort.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (sort) {
                                if (sort != null) {
                                  ref
                                      .read(propertyFilterProvider.notifier)
                                      .state = filter.copyWith(
                                    sort: sort,
                                  );
                                }
                              },
                            ),
                            FilterChip(
                              avatar: const Icon(
                                Icons.event_available_outlined,
                              ),
                              label: const Text('Available now'),
                              selected: filter.availableOnly,
                              onSelected: (selected) =>
                                  ref
                                      .read(propertyFilterProvider.notifier)
                                      .state = filter.copyWith(
                                    availableOnly: selected,
                                  ),
                            ),
                            for (final amenity in _amenities)
                              FilterChip(
                                label: Text(amenity),
                                selected: filter.requiredAmenities.contains(
                                  amenity,
                                ),
                                onSelected: (selected) {
                                  final amenities = {
                                    ...filter.requiredAmenities,
                                  };
                                  selected
                                      ? amenities.add(amenity)
                                      : amenities.remove(amenity);
                                  ref
                                      .read(propertyFilterProvider.notifier)
                                      .state = filter.copyWith(
                                    requiredAmenities: amenities,
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SectionTitle(
                    title: 'Verified homes',
                    subtitle:
                        '${items.length} approved signal${items.length == 1 ? '' : 's'} found',
                    action: StatusPill(
                      label: filter.availableOnly
                          ? 'Available filter on'
                          : 'All statuses',
                      tone: filter.availableOnly
                          ? StatusTone.secure
                          : StatusTone.neutral,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    const GlassPanel(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No homes match your current filters.'),
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 1100
                            ? 3
                            : constraints.maxWidth >= 720
                            ? 2
                            : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: columns == 1 ? 1.12 : 0.82,
                              ),
                          itemBuilder: (context, index) => PropertyCard(
                            property: items[index],
                            onOpen: () =>
                                context.go('/properties/${items[index].id}'),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
