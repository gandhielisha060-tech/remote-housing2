import '../../domain/entities/review.dart';

abstract class ReviewRepository {
  Future<List<PropertyReview>> propertyReviews(String propertyId);
  Future<void> submitReview(PropertyReview review);
  Future<void> deleteReview(String reviewId);
}

class InMemoryReviewRepository implements ReviewRepository {
  final List<PropertyReview> _reviews = [
    PropertyReview(
      id: 'review-1',
      propertyId: 'property-1',
      studentId: 'student-1',
      studentName: 'Aisha Bello',
      comment:
          'The water supply is reliable and the road is easy to access from campus transport.',
      overallRating: 4.5,
      waterRating: 5,
      electricityRating: 4,
      internetRating: 3.5,
      securityRating: 5,
      createdAt: DateTime(2026, 7, 19),
    ),
    PropertyReview(
      id: 'review-2',
      propertyId: 'property-3',
      studentId: 'student-2',
      studentName: 'Daniel Luka',
      comment:
          'Affordable rent, but the room is better for students who do not mind sharing facilities.',
      overallRating: 3.8,
      waterRating: 4,
      electricityRating: 3.5,
      internetRating: 2,
      securityRating: 4,
      createdAt: DateTime(2026, 7, 2),
    ),
  ];

  @override
  Future<List<PropertyReview>> propertyReviews(String propertyId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final reviews = _reviews
        .where((review) => review.propertyId == propertyId)
        .toList();
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  @override
  Future<void> submitReview(PropertyReview review) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final existingIndex = _reviews.indexWhere(
      (item) =>
          item.propertyId == review.propertyId &&
          item.studentId == review.studentId,
    );
    if (existingIndex >= 0) {
      throw Exception('You have already reviewed this property.');
    }
    _reviews.add(review);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    _reviews.removeWhere((review) => review.id == reviewId);
  }
}
