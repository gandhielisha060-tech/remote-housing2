enum PropertyStatus { pending, approved, rejected, suspended }

class HousingProperty {
  const HousingProperty({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.community,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.monthlyRent,
    required this.roomType,
    required this.numberOfRooms,
    required this.amenities,
    required this.imageUrls,
    required this.available,
    required this.status,
    required this.averageRating,
    required this.reviewCount,
    required this.lovedBy,
    required this.createdAt,
  });

  final String id;
  final String landlordId;
  final String title;
  final String description;
  final String community;
  final String address;
  final double latitude;
  final double longitude;
  final int monthlyRent;
  final String roomType;
  final int numberOfRooms;
  final Set<String> amenities;
  final List<String> imageUrls;
  final bool available;
  final PropertyStatus status;
  final double averageRating;
  final int reviewCount;
  final Set<String> lovedBy;
  final DateTime createdAt;

  HousingProperty copyWith({
    PropertyStatus? status,
    bool? available,
    int? monthlyRent,
    Set<String>? amenities,
    Set<String>? lovedBy,
  }) {
    return HousingProperty(
      id: id,
      landlordId: landlordId,
      title: title,
      description: description,
      community: community,
      address: address,
      latitude: latitude,
      longitude: longitude,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      roomType: roomType,
      numberOfRooms: numberOfRooms,
      amenities: amenities ?? this.amenities,
      imageUrls: imageUrls,
      available: available ?? this.available,
      status: status ?? this.status,
      averageRating: averageRating,
      reviewCount: reviewCount,
      lovedBy: lovedBy ?? this.lovedBy,
      createdAt: createdAt,
    );
  }
}

class PropertyFilter {
  const PropertyFilter({
    this.query = '',
    this.community,
    this.maxRent,
    this.rooms,
    this.requiredAmenities = const {},
    this.availableOnly = true,
    this.sort = PropertySort.nearest,
  });

  final String query;
  final String? community;
  final int? maxRent;
  final int? rooms;
  final Set<String> requiredAmenities;
  final bool availableOnly;
  final PropertySort sort;
}

enum PropertySort { nearest, lowestPrice, highestRating, newest, mostReviewed }

extension PropertyStatusLabel on PropertyStatus {
  String get label => switch (this) {
    PropertyStatus.pending => 'Pending',
    PropertyStatus.approved => 'Approved',
    PropertyStatus.rejected => 'Rejected',
    PropertyStatus.suspended => 'Suspended',
  };
}

extension PropertySortLabel on PropertySort {
  String get label => switch (this) {
    PropertySort.nearest => 'Nearest',
    PropertySort.lowestPrice => 'Lowest price',
    PropertySort.highestRating => 'Highest rating',
    PropertySort.newest => 'Newest',
    PropertySort.mostReviewed => 'Most reviewed',
  };
}

extension PropertyFilterCopy on PropertyFilter {
  PropertyFilter copyWith({
    String? query,
    String? community,
    bool clearCommunity = false,
    int? maxRent,
    bool clearMaxRent = false,
    int? rooms,
    bool clearRooms = false,
    Set<String>? requiredAmenities,
    bool? availableOnly,
    PropertySort? sort,
  }) {
    return PropertyFilter(
      query: query ?? this.query,
      community: clearCommunity ? null : community ?? this.community,
      maxRent: clearMaxRent ? null : maxRent ?? this.maxRent,
      rooms: clearRooms ? null : rooms ?? this.rooms,
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      availableOnly: availableOnly ?? this.availableOnly,
      sort: sort ?? this.sort,
    );
  }
}
