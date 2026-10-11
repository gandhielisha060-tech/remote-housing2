enum UserRole { student, landlord, admin }

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.emailVerified = false,
    this.suspended = false,
    this.phone,
    this.studentId,
    this.institution,
    this.department,
    this.propertyAddress,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool emailVerified;
  final bool suspended;
  final String? phone;
  final String? studentId;
  final String? institution;
  final String? department;
  final String? propertyAddress;

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    bool? emailVerified,
    bool? suspended,
    String? phone,
    String? studentId,
    String? institution,
    String? department,
    String? propertyAddress,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      suspended: suspended ?? this.suspended,
      phone: phone ?? this.phone,
      studentId: studentId ?? this.studentId,
      institution: institution ?? this.institution,
      department: department ?? this.department,
      propertyAddress: propertyAddress ?? this.propertyAddress,
    );
  }
}

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.student => 'Student',
    UserRole.landlord => 'Landlord',
    UserRole.admin => 'Administrator',
  };
}
