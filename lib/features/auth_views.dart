import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';
import '../core/widgets/shared_widgets.dart';
import '../core/viewmodels/viewmodels.dart';

// --- 1. SPLASH SCREEN ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        context.go('/onboarding/1');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Text('✨', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                    AppSpacing.heightM,
                    Text(
                      'MiGoalPilot',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: Colors.white,
                        letterSpacing: -1.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.heightXS,
                    Text(
                      'Fly Closer to Your Dreams.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- 2, 3, 4. ONBOARDING SCREENS ---
class OnboardingScreen extends StatelessWidget {
  final int step;

  const OnboardingScreen({super.key, required this.step});

  String _getTitle() {
    switch (step) {
      case 1:
        return 'Your goals deserve\na clear destination.';
      case 2:
        return 'Know exactly where\nyour savings stand.';
      case 3:
      default:
        return 'Let AI help navigate\nyour financial gaps.';
    }
  }

  String _getDescription() {
    switch (step) {
      case 1:
        return 'Turn dreams into calculated, actionable savings plans. Keep multiple goals in perfect balance.';
      case 2:
        return 'Track target dates, gold price indices, wedding plans and milestones in a single, minimal feed.';
      case 3:
      default:
        return 'Ask our copilot questions, run guest what-ifs, and adjust plans seamlessly when life changes.';
    }
  }

  String _getEmoji() {
    switch (step) {
      case 1:
        return '🎯';
      case 2:
        return '📈';
      case 3:
      default:
        return '✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: isLight
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: isLight
                      ? AppColors.primary.withValues(alpha: 0.03)
                      : AppColors.surfaceDark,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getEmoji(),
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _getTitle(),
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
              AppSpacing.heightM,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  _getDescription(),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isLight
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final active = index == (step - 1);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? (isLight
                                ? AppColors.primary
                                : AppColors.primaryDark)
                          : (isLight ? AppColors.border : AppColors.borderDark),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              if (step < 3)
                PrimaryButton(
                  text: 'Next',
                  onPressed: () => context.go('/onboarding/${step + 1}'),
                )
              else
                Column(
                  children: [
                    PrimaryButton(
                      text: 'Create Account',
                      onPressed: () => context.go('/register'),
                    ),
                    AppSpacing.heightS,
                    SecondaryButton(
                      text: 'Sign In',
                      onPressed: () => context.go('/login'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 5. LOGIN SCREEN ---
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
      appBar: MiBackAppBar(
        title: 'Sign In',
        onBackPressed: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/onboarding/3');
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              // Hero Creative Header Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.primary : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 6),
                              Text(
                                'MIGOALPILOT CO-PILOT',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.shield_outlined,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Fly closer to your dreams with smart financial balance.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Container Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.error != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  state.error!,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.heightM,
                      ],
                      AppTextField(
                        label: 'Email address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          size: 20,
                          color: isLight
                              ? AppColors.primary
                              : AppColors.primaryDark,
                        ),
                        validator: (val) => val == null || !val.contains('@')
                            ? 'Enter a valid email'
                            : null,
                      ),
                      AppSpacing.heightM,
                      AppTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: _obscure,
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: isLight
                              ? AppColors.primary
                              : AppColors.primaryDark,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: isLight
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryDark,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (val) => val == null || val.length < 6
                            ? 'Password must be 6+ characters'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.go('/forgot-password'),
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.caption.copyWith(
                              color: isLight
                                  ? AppColors.primary
                                  : AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        text: 'Sign In',
                        isLoading: state.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Creative Footer Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.softSurface : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isLight
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryDark,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            'Create Account',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isLight
                                  ? AppColors.primary
                                  : AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_clock_outlined,
                          size: 14,
                          color: isLight
                              ? AppColors.textLight
                              : AppColors.textLightDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '256-Bit Bank-Grade Encryption • Private & Secure',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: isLight
                                ? AppColors.textLight
                                : AppColors.textLightDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 6. REGISTER SCREEN ---
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
  bool _obscure = true;
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
      appBar: MiBackAppBar(
        title: 'Create Account',
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              // Hero Creative Header Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.primary : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🎯', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 6),
                              Text(
                                'START YOUR FLIGHT PLAN',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Create Account',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Join MiGoalPilot to navigate towards what matters most.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Container Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: isLight
                              ? AppColors.primary
                              : AppColors.primaryDark,
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter your name' : null,
                      ),
                      AppSpacing.heightM,
                      AppTextField(
                        label: 'Email address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          size: 20,
                          color: isLight
                              ? AppColors.primary
                              : AppColors.primaryDark,
                        ),
                        validator: (val) => val == null || !val.contains('@')
                            ? 'Enter a valid email'
                            : null,
                      ),
                      AppSpacing.heightM,
                      AppTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: _obscure,
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: isLight
                              ? AppColors.primary
                              : AppColors.primaryDark,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: isLight
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryDark,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (val) => val == null || val.length < 6
                            ? 'Password must be 6+ characters'
                            : null,
                      ),
                      AppSpacing.heightM,
                      AppTextField(
                        label: 'Confirm Password',
                        controller: _confirmController,
                        obscureText: _obscure,
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: isLight
                              ? AppColors.primary
                              : AppColors.primaryDark,
                        ),
                        validator: (val) => val != _passwordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      AppSpacing.heightS,
                      CheckboxListTile(
                        title: Text(
                          'I agree to the Terms & Privacy Policy',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLight
                                ? AppColors.textPrimary
                                : AppColors.textPrimaryDark,
                          ),
                        ),
                        value: _agree,
                        onChanged: (val) => setState(() => _agree = val ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: isLight
                            ? AppColors.primary
                            : AppColors.accent,
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        text: 'Create Plan Account',
                        isLoading: state.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Creative Footer Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.softSurface : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isLight
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryDark,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Sign In',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isLight
                                  ? AppColors.primary
                                  : AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 14,
                          color: isLight
                              ? AppColors.textLight
                              : AppColors.textLightDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Zero Data Sharing • 100% Private Savings Co-Pilot',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: isLight
                                ? AppColors.textLight
                                : AppColors.textLightDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 7. FORGOT PASSWORD ---
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

// --- 8. GOAL SELECTION ---
class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      appBar: MiBackAppBar(
        title: 'Choose Path',
        onBackPressed: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Create a New Plan',
              style: AppTextStyles.displayMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.heightS,
            Text(
              'Input parameters manually or describe your dream to GoalPilot AI.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isLight
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),

            // Manual Box
            InkWell(
              onTap: () => context.go('/create-goal'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLight ? AppColors.border : AppColors.borderDark,
                  ),
                ),
                child: Column(
                  children: [
                    const Text('✍️', style: TextStyle(fontSize: 32)),
                    AppSpacing.heightS,
                    const Text(
                      'Manual Goal Builder',
                      style: AppTextStyles.titleLarge,
                    ),
                    AppSpacing.heightXS,
                    Text(
                      'Target amount, deadlines, categories and custom weekly targets.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isLight
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // AI Box
            InkWell(
              onTap: () => context.go('/ai-goal-creation'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: isLight
                      ? AppColors.secondary.withValues(alpha: 0.04)
                      : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLight
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.primaryDark.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 32)),
                    AppSpacing.heightS,
                    const Text(
                      'Create with GoalPilot AI',
                      style: AppTextStyles.titleLarge,
                    ),
                    AppSpacing.heightXS,
                    Text(
                      'Tell our copilot your target naturally and let AI draft the steps.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isLight
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
