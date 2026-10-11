enum ReportReason {
  fakeListing,
  scam,
  wrongInformation,
  duplicateListing,
  abuse,
}

class PropertyReport {
  const PropertyReport({
    required this.id,
    required this.propertyId,
    required this.studentId,
    required this.reason,
    required this.details,
    required this.createdAt,
    this.resolved = false,
  });

  final String id;
  final String propertyId;
  final String studentId;
  final ReportReason reason;
  final String details;
  final DateTime createdAt;
  final bool resolved;
}

extension ReportReasonLabel on ReportReason {
  String get label => switch (this) {
    ReportReason.fakeListing => 'Fake listing',
    ReportReason.scam => 'Scam',
    ReportReason.wrongInformation => 'Wrong information',
    ReportReason.duplicateListing => 'Duplicate listing',
    ReportReason.abuse => 'Abuse',
  };
}
