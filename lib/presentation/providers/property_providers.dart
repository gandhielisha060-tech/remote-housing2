import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/service_locator.dart';
import '../../data/repositories/property_repository.dart';
import '../../domain/entities/property.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return getIt<PropertyRepository>();
});

final propertyFilterProvider = StateProvider<PropertyFilter>((ref) {
  return const PropertyFilter();
});

final propertiesProvider = FutureProvider<List<HousingProperty>>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  final filter = ref.watch(propertyFilterProvider);
  return repository.search(filter);
});

final propertyByIdProvider = FutureProvider.family<HousingProperty?, String>((
  ref,
  id,
) {
  return ref.watch(propertyRepositoryProvider).findById(id);
});

final landlordPropertiesProvider =
    FutureProvider.family<List<HousingProperty>, String>((ref, landlordId) {
      return ref
          .watch(propertyRepositoryProvider)
          .landlordProperties(landlordId);
    });

final pendingPropertiesProvider = FutureProvider<List<HousingProperty>>((
  ref,
) async {
  return ref.watch(propertyRepositoryProvider).pendingListings();
});
