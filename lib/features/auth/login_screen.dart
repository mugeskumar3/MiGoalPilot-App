import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_text_styles.dart';
import 'package:migoalpilot_app/core/widgets/shared_widgets.dart';
import 'package:migoalpilot_app/core/viewmodels/viewmodels.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'mugesh@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(authViewModelProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text.trim());
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
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLight 
                            ? AppColors.primary.withValues(alpha: 0.08) 
                            : AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '✈️ MiGoalPilot',
                        style: AppTextStyles.caption.copyWith(
                          color: isLight ? AppColors.primary : AppColors.accentDark,
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
                  'Welcome Back',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to consult your personal goal co-pilot.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
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
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
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
                  label: 'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Password must be 6+ characters' : null,
                ),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: isLight ? AppColors.primary : AppColors.accentDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                PrimaryButton(
                  text: 'Sign In',
                  onPressed: _submit,
                  isLoading: state.isLoading,
                ),
                const SizedBox(height: 16),
                
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚡ Biometric Face ID / Passkey authentication ready.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.fingerprint_rounded, 
                    size: 20, 
                    color: isLight ? AppColors.primary : AppColors.accentDark,
                  ),
                  label: Text(
                    'Sign in with Biometrics',
                    style: TextStyle(
                      color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(
                      color: isLight ? AppColors.border : AppColors.borderDark,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: isLight ? AppColors.primary : AppColors.accentDark,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Terms Notice
                Center(
                  child: Text(
                    'By continuing, you agree to our Terms & Privacy Policy\nPowered by Jeev Labs',
                    style: AppTextStyles.caption.copyWith(
                      color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
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
