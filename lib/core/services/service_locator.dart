import 'package:get_it/get_it.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/property_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/repositories/review_repository.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  if (getIt.isRegistered<AuthRepository>()) return;

  getIt
    ..registerLazySingleton<AuthRepository>(SqliteAuthRepository.new)
    ..registerLazySingleton<PropertyRepository>(InMemoryPropertyRepository.new)
    ..registerLazySingleton<ReviewRepository>(InMemoryReviewRepository.new)
    ..registerLazySingleton<ReportRepository>(InMemoryReportRepository.new);
}
