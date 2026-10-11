import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/service_locator.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIt<AuthRepository>();
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.watch(authRepositoryProvider));
  },
);

class AuthState {
  const AuthState({this.user, this.loading = false, this.error});

  final AppUser? user;
  final bool loading;
  final String? error;

  AuthState copyWith({
    AppUser? user,
    bool clearUser = false,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      loading: loading ?? this.loading,
      error: clearError ? null : error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository)
    : super(AuthState(user: _repository.currentUser));

  final AuthRepository _repository;

  Future<void> signIn({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final user = await _repository.signIn(
        email: email,
        password: password,
        role: role,
      );
      state = AuthState(user: user);
    } on Object catch (error) {
      state = state.copyWith(loading: false, error: _friendlyError(error));
    }
  }

  Future<void> register({
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
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repository.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
        studentId: studentId,
        institution: institution,
        department: department,
        propertyAddress: propertyAddress,
      );
      state = const AuthState();
    } on Object catch (error) {
      state = state.copyWith(loading: false, error: _friendlyError(error));
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ') ? message.substring(11) : message;
  }
}
