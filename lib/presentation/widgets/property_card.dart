import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/property.dart';
import '../providers/auth_provider.dart';
import '../providers/property_providers.dart';

class PropertyCard extends ConsumerWidget {
  const PropertyCard({
    required this.property,
    required this.onOpen,
    this.trailing,
    super.key,
  });

  final HousingProperty property;
  final VoidCallback onOpen;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userId = ref.watch(authControllerProvider).user?.id;
    final repo = ref.read(propertyRepositoryProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reduce image size by 3x by adjusting aspect ratio and limiting height
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: property.imageUrls.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.apartment),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          trailing ?? const SizedBox.shrink(),
                          const SizedBox(width: 6),
                          IconButton(
                            tooltip: 'Love',
                            onPressed: userId == null
                                ? null
                                : () async {
                                    await repo.toggleLove(property.id, userId);
                                    ref.invalidate(propertiesProvider);
                                    ref.invalidate(
                                      propertyByIdProvider(property.id),
                                    );
                                  },
                            icon: Icon(
                              property.lovedBy.contains(userId)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: property.lovedBy.contains(userId)
                                  ? Colors.red
                                  : theme.iconTheme.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${property.community} - ${property.roomType}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.payments_outlined,
                        label: 'NGN ${property.monthlyRent}/mo',
                      ),
                      _InfoChip(
                        icon: Icons.meeting_room_outlined,
                        label: '${property.numberOfRooms} room',
                      ),
                      _InfoChip(
                        icon: Icons.star_rounded,
                        label:
                            '${property.averageRating.toStringAsFixed(1)} (${property.reviewCount})',
                      ),
                      _InfoChip(
                        icon: Icons.verified_outlined,
                        label: property.status.label,
                      ),
                    ],
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
 