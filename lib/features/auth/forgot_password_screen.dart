import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_spacing.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLight
          ? AppColors.background
          : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Recover Password',
        onBackPressed: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/login');
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: _submitted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : AppColors.surfaceDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLight
                              ? AppColors.border
                              : AppColors.borderDark,
                        ),
                      ),
                      child: const Text('✉️', style: TextStyle(fontSize: 48)),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Recovery Link Sent',
                      style: AppTextStyles.displayMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.heightS,
                    Text(
                      'Check your inbox. We sent password recovery instructions to ${_emailController.text}.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isLight
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 48),
                    PrimaryButton(
                      text: 'Back to Sign In',
                      onPressed: () => context.go('/login'),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset Password',
                      style: AppTextStyles.displayLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email address and we\'ll send recovery instructions.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isLight
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 48),
                    AppTextField(
                      label: 'Email address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Send Reset Instructions',
                      onPressed: () {
                        if (_emailController.text.contains('@')) {
                          setState(() => _submitted = true);
                        }
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
