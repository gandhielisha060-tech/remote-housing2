import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../data/local/sqlite_database.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthRepository {
  AppUser? get currentUser;

  Future<AppUser> signIn({
    required String email,
    required String password,
    UserRole? role,
  });

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? studentId,
    String? institution,
    String? department,
    String? propertyAddress,
  });

  Future<AppUser?> findById(String id);
  Future<void> signOut();
}

class SqliteAuthRepository implements AuthRepository {
  SqliteAuthRepository({SqliteDatabase? database})
    : _database = database ?? SqliteDatabase() {
    _ready = _initialize();
  }

  final SqliteDatabase _database;
  late final Future<void> _ready;
  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  Future<Database> _openDatabase() async {
    final database = await _database.database;
    if (database == null) {
      throw Exception(
        'Local account storage is unavailable. Please reload the app and try again.',
      );
    }
    return database;
  }

  Future<void> _initialize() async {
    final database = await _openDatabase();
    await _seedAccount(
      database,
      id: 'student-1',
      name: 'Aisha Bello',
      email: 'student@mau.edu.ng',
      password: 'student123',
      role: UserRole.student,
      studentId: 'MAU/ST/001',
      institution: 'Maranatha University',
      department: 'Computer Science',
    );
    await _seedAccount(
      database,
      id: 'landlord-1',
      name: 'Mr. Yakubu Musa',
      email: 'landlord@example.com',
      password: 'landlord123',
      role: UserRole.landlord,
      phone: '+2348012345678',
      propertyAddress: 'Ikeja, Lagos',
    );
    await _seedAccount(
      database,
      id: 'admin-1',
      name: 'Housing Admin',
      email: 'admin@mau.edu.ng',
      password: 'admin123',
      role: UserRole.admin,
    );
    await _seedAccount(
      database,
      id: 'admin-owner',
      name: 'Owner Admin',
      email: 'jzacks543@gmail.com',
      password: '223344',
      role: UserRole.admin,
    );
  }

  Future<void> _seedAccount(
    Database database, {
    required String id,
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? studentId,
    String? institution,
    String? department,
    String? propertyAddress,
  }) async {
    final existing = await database.query(
      'users',
      columns: const ['id'],
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    await database.insert('users', {
      'id': id,
      'name': name,
      'email': email.toLowerCase(),
      'password_hash': _hashPassword(password),
      'role': role.name,
      'phone': phone,
      'student_id': studentId,
      'institution': institution,
      'department': department,
      'property_address': propertyAddress,
      'email_verified': 1,
      'suspended': 0,
    });
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    await _ready;
    final database = await _openDatabase();
    final normalizedEmail = email.trim().toLowerCase();
    final rows = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw Exception('No account found for this email.');
    }

    final row = rows.first;
    final user = _userFromRow(row);
    if (role != null && user.role != role) {
      throw Exception(
        'This account is not registered as a ${role.label}.',
      );
    }
    if (user.suspended) {
      throw Exception('This account is suspended.');
    }
    if (row['password_hash'] != _hashPassword(password)) {
      throw Exception('Incorrect email or password.');
    }

    _currentUser = user;
    return user;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? studentId,
    String? institution,
    String? department,
    String? propertyAddress,
  }) async {
    await _ready;
    final database = await _openDatabase();
    final normalizedEmail = email.trim().toLowerCase();

    if (role == UserRole.admin &&
        (normalizedEmail != 'jzacks543@gmail.com' || password != '223344')) {
      throw Exception(
        'Admin registration is restricted to the owner administrator account.',
      );
    }

    final existing = await database.query(
      'users',
      columns: const ['id'],
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw Exception('An account already exists for this email.');
    }

    final id =
        '${role.name}-${DateTime.now().microsecondsSinceEpoch}';
    final user = AppUser(
      id: id,
      name: name.trim(),
      email: normalizedEmail,
      role: role,
      phone: phone,
      studentId: studentId,
      institution: institution,
      department: department,
      propertyAddress: propertyAddress,
    );

    await database.insert('users', {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password_hash': _hashPassword(password),
      'role': user.role.name,
      'phone': user.phone,
      'student_id': user.studentId,
      'institution': user.institution,
      'department': user.department,
      'property_address': user.propertyAddress,
      'email_verified': 0,
      'suspended': 0,
    });

    _currentUser = user;
    return user;
  }

  @override
  Future<AppUser?> findById(String id) async {
    await _ready;
    final database = await _openDatabase();
    final rows = await database.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _userFromRow(rows.first);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  AppUser _userFromRow(Map<String, Object?> row) {
    return AppUser(
      id: row['id']! as String,
      name: row['name']! as String,
      email: row['email']! as String,
      role: UserRole.values.byName(row['role']! as String),
      emailVerified: row['email_verified'] == 1,
      suspended: row['suspended'] == 1,
      phone: row['phone'] as String?,
      studentId: row['student_id'] as String?,
      institution: row['institution'] as String?,
      department: row['department'] as String?,
      propertyAddress: row['property_address'] as String?,
    );
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
