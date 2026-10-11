import '../../domain/entities/report.dart';

abstract class ReportRepository {
  Future<List<PropertyReport>> reports();
  Future<void> submitReport(PropertyReport report);
  Future<void> resolveReport(String reportId);
}

class InMemoryReportRepository implements ReportRepository {
  final List<PropertyReport> _reports = [
    PropertyReport(
      id: 'report-1',
      propertyId: 'property-2',
      studentId: 'student-1',
      reason: ReportReason.wrongInformation,
      details:
          'The listing says parking is available, but students nearby say the compound is full.',
      createdAt: DateTime(2026, 7, 21),
    ),
  ];

  @override
  Future<List<PropertyReport>> reports() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final reports = [..._reports];
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  }

  @override
  Future<void> submitReport(PropertyReport report) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    _reports.add(report);
  }

  @override
  Future<void> resolveReport(String reportId) async {
    final index = _reports.indexWhere((report) => report.id == reportId);
    if (index == -1) return;
    final report = _reports[index];
    _reports[index] = PropertyReport(
      id: report.id,
      propertyId: report.propertyId,
      studentId: report.studentId,
      reason: report.reason,
      details: report.details,
      createdAt: report.createdAt,
      resolved: true,
    );
  }
}
