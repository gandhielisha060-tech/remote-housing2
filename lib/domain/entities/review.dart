class PropertyReview {
  const PropertyReview({
    required this.id,
    required this.propertyId,
    required this.studentId,
    required this.studentName,
    required this.comment,
    required this.overallRating,
    required this.waterRating,
    required this.electricityRating,
    required this.internetRating,
    required this.securityRating,
    required this.createdAt,
  });

  final String id;
  final String propertyId;
  final String studentId;
  final String studentName;
  final String comment;
  final double overallRating;
  final double waterRating;
  final double electricityRating;
  final double internetRating;
  final double securityRating;
  final DateTime createdAt;
}
