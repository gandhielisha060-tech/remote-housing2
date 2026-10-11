import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/validators/input_validators.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bar_controls.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _role = UserRole.student;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    ref.listen(authControllerProvider, (previous, next) {
      if (!mounted || next.error == null || next.error == previous?.error) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(next.error!)));
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.home_work_outlined,
                              size: 52,
                              color: colors.primary,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              AppConstants.appName,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Login',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter your account details to continue.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            DropdownButtonFormField<UserRole>(
                              value: _role,
                              decoration: const InputDecoration(
                                labelText: 'Account type',
                                prefixIcon: Icon(Icons.account_circle_outlined),
                              ),
                              items: UserRole.values
                                  .map(
                                    (role) => DropdownMenuItem<UserRole>(
                                      value: role,
                                      child: Text(
                                        role == UserRole.admin
                                            ? 'Admin'
                                            : role.label,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: auth.loading
                                  ? null
                                  : (role) {
                                      if (role != null) {
                                        setState(() => _role = role);
                                      }
                                    },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Gmail / email address',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: emailValidator,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: auth.loading
                                  ? null
                                  : (_) => _login(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                              validator: passwordValidator,
                            ),
                            const SizedBox(height: 22),
                            FilledButton.icon(
                              onPressed: auth.loading ? null : _login,
                              icon: auth.loading
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.login_outlined),
                              label: const Text('Login'),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: _openRegistration,
                              icon: const Icon(Icons.person_add_alt_outlined),
                              label: const Text('Create account'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 8,
              right: 12,
              child: AppBarControls(showLogout: false),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _role,
        );
  }

  void _openRegistration() {
    if (!mounted) return;
    GoRouter.of(context).go('/register');
  }

  IconData _roleIcon(UserRole role) => switch (role) {
    UserRole.student => Icons.school_outlined,
    UserRole.landlord => Icons.apartment_outlined,
    UserRole.admin => Icons.admin_panel_settings_outlined,
  };
}
