import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';
import 'package:migoalpilot/app/constants/app_constants.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final bool _obscure = true;
  bool _agree = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (!_agree) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to terms and conditions.'),
          ),
        );
        return;
      }
      final success = await ref
          .read(authViewModelProvider.notifier)
          .register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      if (success && mounted) {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Premium Tag/Branding
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isLight
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '✈️ ${AppConstants.appName}',
                        style: AppTextStyles.caption.copyWith(
                          color: isLight
                              ? AppColors.primary
                              : AppColors.accentDark,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Headings
                Text(
                  'Create Account',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: isLight
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your journey to calculated financial freedom.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isLight
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 48),

                if (state.error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      state.error!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Input Fields
                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || !val.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscure,
                  validator: (val) => val == null || val.length < 6
                      ? 'Password must be 6+ characters'
                      : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Confirm Password',
                  controller: _confirmController,
                  obscureText: _obscure,
                  validator: (val) => val != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
                const SizedBox(height: 20),

                // Terms Switch
                Row(
                  children: [
                    Checkbox(
                      value: _agree,
                      onChanged: (val) => setState(() => _agree = val ?? false),
                      activeColor: isLight
                          ? AppColors.primary
                          : AppColors.accentDark,
                      checkColor: isLight
                          ? Colors.white
                          : AppColors.backgroundDark,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/privacy?tab=terms'),
                        child: Text(
                          'I agree to the Terms & Privacy Policy',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isLight
                                ? AppColors.primary
                                : AppColors.accentDark,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                PrimaryButton(
                  text: 'Create Account',
                  onPressed: _submit,
                  isLoading: state.isLoading,
                ),
                const SizedBox(height: 32),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isLight
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: isLight
                              ? AppColors.primary
                              : AppColors.accentDark,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Footer
                Center(
                  child: Text(
                    'Your financial goal data is 256-bit encrypted.\nPowered by Jeev Labs',
                    style: AppTextStyles.caption.copyWith(
                      color: isLight
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryDark,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
