import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/validators/input_validators.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bar_controls.dart';
import '../../widgets/soc_widgets.dart';

enum AuthMode { login, register }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({required this.initialMode, super.key});

  final AuthMode initialMode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _institutionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _propertyAddressController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AuthMode _mode = widget.initialMode;
  UserRole _role = UserRole.student;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = true;

  bool get _isRegister => _mode == AuthMode.register;
  bool get _isAdmin => _role == UserRole.admin;

  List<UserRole> get _availableRoles => _isRegister
      ? const [UserRole.student, UserRole.landlord]
      : UserRole.values;

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _emailController,
      _passwordController,
      _phoneController,
      _studentIdController,
      _institutionController,
      _departmentController,
      _propertyAddressController,
      _confirmPasswordController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? 54 : 20,
                    vertical: wide ? 34 : 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 40,
                    ),
                    child: wide
                        ? Row(
                            children: [
                              Expanded(child: _BrandPanel(scheme: scheme)),
                              const SizedBox(width: 54),
                              SizedBox(width: 440, child: _authCard(auth)),
                            ],
                          )
                        : Column(
                            children: [
                              _compactBrand(scheme),
                              const SizedBox(height: 24),
                              _authCard(auth),
                            ],
                          ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: wide ? 42 : 12,
                  child: const AppBarControls(showLogout: false),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _compactBrand(ColorScheme scheme) {
    return Row(
      children: [
        _LogoMark(color: scheme.secondary),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            AppConstants.appName,
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
        ),
      ],
    );
  }

  Widget _authCard(AuthState auth) {
    final scheme = Theme.of(context).colorScheme;
    return GlassPanel(
      padding: const EdgeInsets.all(26),
      accent: scheme.secondary,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isRegister ? 'Create your access' : 'Welcome back',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                StatusPill(
                  label: _isRegister ? 'New account' : 'Secure login',
                  tone: _isRegister ? StatusTone.warning : StatusTone.secure,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isRegister
                  ? 'Join a verified housing network around MAU.'
                  : 'Sign in to continue to your housing workspace.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            const SizedBox(height: 20),
            Text(
              'Account role',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            SegmentedButton<UserRole>(
              segments: _availableRoles
                  .map(
                    (role) => ButtonSegment(
                      value: role,
                      label: Text(
                        role == UserRole.admin ? 'Admin' : role.label,
                      ),
                      icon: Icon(_roleIcon(role)),
                    ),
                  )
                  .toList(),
              selected: {_role},
              onSelectionChanged: auth.loading
                  ? null
                  : (selection) => setState(() => _role = selection.first),
            ),
            if (!_isRegister && _isAdmin) ...[
              const SizedBox(height: 10),
              const StatusPill(
                label: 'Owner administrator access',
                tone: StatusTone.info,
              ),
            ],
            const SizedBox(height: 16),
            if (_isRegister) ...[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: requiredField,
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Gmail / email address',
                hintText: _isAdmin ? 'jzacks543@gmail.com' : null,
                prefixIcon: const Icon(Icons.mail_outline),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final message = emailValidator(value);
                if (message != null) return message;

                return null;
              },
            ),
            if (_isRegister) ...[
              const SizedBox(height: 12),
              _textField(
                _phoneController,
                'Phone number',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],

            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              validator: passwordValidator,
            ),
            if (_isRegister) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _obscureConfirmPassword
                        ? 'Show password'
                        : 'Hide password',
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm password is required';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
            if (!_isRegister)
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) =>
                        setState(() => _rememberMe = value ?? true),
                  ),
                  const Text('Remember me'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password recovery is coming soon.'),
                      ),
                    ),
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: auth.loading ? null : _submit,
              icon: auth.loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _isRegister
                          ? Icons.person_add_alt_outlined
                          : Icons.login_outlined,
                    ),
              label: Text(_isRegister ? 'Create account' : 'Login'),
            ),
            if (!_isRegister) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _openRegistration,
                icon: const Icon(Icons.person_add_alt_outlined),
                label: const Text('Create account'),
              ),
            ],
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Your account is protected by verified listing moderation.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRegistration() {
    ref.read(authControllerProvider.notifier).clearError();
    if (!mounted) return;
    GoRouter.of(context).go('/register');
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      keyboardType: keyboardType,
      validator: requiredField,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(authControllerProvider.notifier);
    if (!_isRegister) {
      await controller.signIn(
        email: _emailController.text,
        password: _passwordController.text,
        role: _role,
      );
      return;
    }

    await controller.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _role,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      studentId: _studentIdController.text.trim().isEmpty
          ? null
          : _studentIdController.text.trim(),
      institution: _institutionController.text.trim().isEmpty
          ? null
          : _institutionController.text.trim(),
      department: _departmentController.text.trim().isEmpty
          ? null
          : _departmentController.text.trim(),
      propertyAddress: _propertyAddressController.text.trim().isEmpty
          ? null
          : _propertyAddressController.text.trim(),
    );
    if (!mounted) return;
    if (ref.read(authControllerProvider).error != null) return;
    for (final field in [
      _nameController,
      _emailController,
      _passwordController,
      _phoneController,
      _studentIdController,
      _institutionController,
      _departmentController,
      _propertyAddressController,
      _confirmPasswordController,
    ]) {
      field.clear();
    }
    setState(() => _mode = AuthMode.login);
    context.go('/login');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created. Please log in manually.')),
    );
  }

  IconData _roleIcon(UserRole role) => switch (role) {
    UserRole.student => Icons.school_outlined,
    UserRole.landlord => Icons.apartment_outlined,
    UserRole.admin => Icons.admin_panel_settings_outlined,
  };
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LogoMark(color: scheme.secondary),
            const SizedBox(width: 14),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 72),
        Text(
          'Find a home with\nbetter signals.',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.02,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'A trusted student housing workspace for verified homes, transparent reviews, and fast landlord coordination around MAU.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 36),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            StatusPill(label: 'Listings verified', tone: StatusTone.secure),
            StatusPill(label: 'MAU proximity data', tone: StatusTone.info),
            StatusPill(label: 'Moderated reports', tone: StatusTone.warning),
          ],
        ),
        const SizedBox(height: 46),
        GlassPanel(
          accent: scheme.primary,
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: scheme.primary, size: 32),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Every approved listing carries a clear status, location signal, and student feedback trail.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.62)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.home_work_outlined, color: color),
    );
  }
}
