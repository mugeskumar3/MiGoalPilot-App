import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_spacing.dart';
import 'package:migoalpilot_app/app/theme/app_text_styles.dart';
import 'package:migoalpilot_app/core/widgets/shared_widgets.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _submitted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('✉️', style: TextStyle(fontSize: 64)),
                  AppSpacing.heightM,
                  const Text(
                    'Recovery Link Sent',
                    style: AppTextStyles.headlineLarge,
                  ),
                  AppSpacing.heightS,
                  Text(
                    'Check your inbox. We sent password recovery instructions to ${_emailController.text}.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isLight
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryDark,
                    ),
                  ),
                  AppSpacing.heightXL,
                  PrimaryButton(
                    text: 'Back to Sign In',
                    onPressed: () => context.go('/login'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reset Password',
                    style: AppTextStyles.displayMedium,
                  ),
                  AppSpacing.heightXS,
                  Text(
                    'Enter your email address and we\'ll send recovery instructions.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isLight
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: 'Email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
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
    );
  }
}
