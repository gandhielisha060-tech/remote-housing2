import '../../domain/entities/property.dart';

abstract class PropertyRepository {
  Future<List<HousingProperty>> search(PropertyFilter filter);
  Future<List<HousingProperty>> landlordProperties(String landlordId);
  Future<List<HousingProperty>> pendingListings();
  Future<HousingProperty?> findById(String id);
  Future<HousingProperty> create(HousingProperty property);
  Future<void> updateStatus(String id, PropertyStatus status);
  Future<void> delete(String id, String landlordId);
  Future<void> toggleLove(String id, String userId);
}

class InMemoryPropertyRepository implements PropertyRepository {
  final List<HousingProperty> _properties = [
    HousingProperty(
      id: 'property-1',
      landlordId: 'landlord-1',
      title: 'Quiet self-contained room near MAU Gate',
      description:
          'A secure self-contained room with steady water, prepaid electricity, and walking access to campus transport.',
      community: 'Sangere',
      address: 'Sangere Road, close to MAU main gate',
      latitude: 9.3118,
      longitude: 12.4808,
      monthlyRent: 45000,
      roomType: 'Self-contained',
      numberOfRooms: 1,
      amenities: {'Water', 'Electricity', 'Security', 'Bathroom'},
      imageUrls: const [
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=1000&q=80',
      ],
      available: true,
      status: PropertyStatus.approved,
      averageRating: 4.6,
      reviewCount: 18,
      lovedBy: {},
      createdAt: DateTime(2026, 7, 10),
    ),
    HousingProperty(
      id: 'property-2',
      landlordId: 'landlord-1',
      title: 'Two-bedroom flat with parking',
      description:
          'Spacious flat suitable for students sharing rent. Includes kitchen, fenced compound, and landlord contact verification.',
      community: 'Girei',
      address: 'Girei Junction extension',
      latitude: 9.3612,
      longitude: 12.5489,
      monthlyRent: 90000,
      roomType: 'Flat',
      numberOfRooms: 2,
      amenities: {'Water', 'Electricity', 'Security', 'Kitchen', 'Parking'},
      imageUrls: const [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1000&q=80',
      ],
      available: true,
      status: PropertyStatus.pending,
      averageRating: 4.1,
      reviewCount: 7,
      lovedBy: {},
      createdAt: DateTime(2026, 7, 18),
    ),
    HousingProperty(
      id: 'property-3',
      landlordId: 'landlord-2',
      title: 'Budget room in Wuro Hausa',
      description:
          'Affordable room for students who need lower rent and direct access to local markets.',
      community: 'Wuro Hausa',
      address: 'Wuro Hausa student axis',
      latitude: 9.2975,
      longitude: 12.4582,
      monthlyRent: 28000,
      roomType: 'Single room',
      numberOfRooms: 1,
      amenities: {'Water', 'Electricity'},
      imageUrls: const [
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1000&q=80',
      ],
      available: false,
      status: PropertyStatus.approved,
      averageRating: 3.8,
      reviewCount: 22,
      lovedBy: {},
      createdAt: DateTime(2026, 6, 28),
    ),
  ];

  @override
  Future<List<HousingProperty>> search(PropertyFilter filter) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    var result = _properties.where(
      (property) => property.status == PropertyStatus.approved,
    );
    if (filter.availableOnly) {
      result = result.where((property) => property.available);
    }
    if (filter.query.trim().isNotEmpty) {
      final query = filter.query.trim().toLowerCase();
      result = result.where(
        (property) =>
            property.title.toLowerCase().contains(query) ||
            property.community.toLowerCase().contains(query) ||
            property.address.toLowerCase().contains(query),
      );
    }
    if (filter.community != null && filter.community!.isNotEmpty) {
      result = result.where(
        (property) => property.community == filter.community,
      );
    }
    if (filter.maxRent != null) {
      result = result.where(
        (property) => property.monthlyRent <= filter.maxRent!,
      );
    }
    if (filter.rooms != null) {
      result = result.where(
        (property) => property.numberOfRooms >= filter.rooms!,
      );
    }
    if (filter.requiredAmenities.isNotEmpty) {
      result = result.where(
        (property) => property.amenities.containsAll(filter.requiredAmenities),
      );
    }
    final list = result.toList();
    switch (filter.sort) {
      case PropertySort.lowestPrice:
        list.sort((a, b) => a.monthlyRent.compareTo(b.monthlyRent));
      case PropertySort.highestRating:
        list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      case PropertySort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case PropertySort.mostReviewed:
        list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
      case PropertySort.nearest:
        list.sort((a, b) => a.community.compareTo(b.community));
    }
    return list;
  }

  @override
  Future<List<HousingProperty>> landlordProperties(String landlordId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final listings = _properties
        .where((property) => property.landlordId == landlordId)
        .toList();
    listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return listings;
  }

  @override
  Future<List<HousingProperty>> pendingListings() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final listings = _properties
        .where((property) => property.status == PropertyStatus.pending)
        .toList();
    listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return listings;
  }

  @override
  Future<HousingProperty?> findById(String id) async {
    try {
      return _properties.firstWhere((property) => property.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<HousingProperty> create(HousingProperty property) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _properties.insert(0, property);
    return property;
  }

  @override
  Future<void> updateStatus(String id, PropertyStatus status) async {
    final index = _properties.indexWhere((property) => property.id == id);
    if (index == -1) {
      return;
    }
    _properties[index] = _properties[index].copyWith(status: status);
  }

  @override
  Future<void> delete(String id, String landlordId) async {
    _properties.removeWhere(
      (property) => property.id == id && property.landlordId == landlordId,
    );
  }

  @override
  Future<void> toggleLove(String id, String userId) async {
    final index = _properties.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final current = _properties[index];
    final loved = {...current.lovedBy};
    if (loved.contains(userId)) {
      loved.remove(userId);
    } else {
      loved.add(userId);
    }
    _properties[index] = current.copyWith(lovedBy: loved);
  }
}
