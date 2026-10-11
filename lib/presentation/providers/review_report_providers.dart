import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/service_locator.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/review.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return getIt<ReviewRepository>();
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return getIt<ReportRepository>();
});

final propertyReviewsProvider =
    FutureProvider.family<List<PropertyReview>, String>((ref, propertyId) {
      return ref.watch(reviewRepositoryProvider).propertyReviews(propertyId);
    });

final reportsProvider = FutureProvider<List<PropertyReport>>((ref) {
  return ref.watch(reportRepositoryProvider).reports();
});
