import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/app_user.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/landlord/add_property_screen.dart';
import '../../presentation/screens/landlord/landlord_dashboard_screen.dart';
import '../../presentation/screens/landlord/landlord_contact_screen.dart';
import '../../presentation/screens/property/property_detail_screen.dart';
import '../../presentation/screens/student/agent_contact_screen.dart';
import '../../presentation/screens/student/student_dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/register';
      final user = authState.user;

      if (user == null) {
        return isAuthRoute ? null : '/login';
      }

      if (path.startsWith('/landlords/') && user.role != UserRole.admin) {
        return _homePath(user.role);
      }

      if (path.startsWith('/agent-contact/') && user.role != UserRole.student) {
        return _homePath(user.role);
      }

      if (isAuthRoute || path == '/') {
        return _homePath(user.role);
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            const AuthScreen(initialMode: AuthMode.register),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/landlord',
        builder: (context, state) => const LandlordDashboardScreen(),
      ),
      GoRoute(
        path: '/landlord/add-property',
        builder: (context, state) => const AddPropertyScreen(),
      ),
      GoRoute(
        path: '/landlords/:id',
        builder: (context, state) =>
            LandlordContactScreen(landlordId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/agent-contact/:id',
        builder: (context, state) =>
            AgentContactScreen(propertyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/properties/:id',
        builder: (context, state) =>
            PropertyDetailScreen(propertyId: state.pathParameters['id']!),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go(
            authState.user == null ? '/login' : _homePath(authState.user!.role),
          ),
          child: const Text('Go home'),
        ),
      ),
    ),
  );
});

String _homePath(UserRole role) {
  return switch (role) {
    UserRole.student => '/student',
    UserRole.landlord => '/landlord',
    UserRole.admin => '/admin',
  };
}
