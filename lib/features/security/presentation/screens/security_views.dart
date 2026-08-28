import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/security_state.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _error;

  void _handleNumber(int val) {
    setState(() {
      _error = null;
      if (!_isConfirming) {
        if (_pin.length < 4) _pin += val.toString();
      } else {
        if (_confirmPin.length < 4) _confirmPin += val.toString();
      }
    });
  }

  void _handleDelete() {
    setState(() {
      if (!_isConfirming) {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else {
        if (_confirmPin.isNotEmpty) _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      }
    });
  }

  void _handleNext() async {
    if (!_isConfirming) {
      if (_pin.length < 4) {
        setState(() => _error = 'Passcode PIN must be exactly 4 digits');
        return;
      }
      setState(() => _isConfirming = true);
    } else {
      if (_confirmPin.length < 4) {
        setState(() => _error = 'Please confirm your 4-digit passcode');
        return;
      }
      if (_pin != _confirmPin) {
        setState(() {
          _confirmPin = '';
          _error = 'PINs do not match. Try again.';
        });
        return;
      }
      // Save PIN
      await ref.read(securityViewModelProvider.notifier).setPin(_pin);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final currentText = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Passcode PIN Setup',
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              _isConfirming ? 'Confirm passcode PIN' : 'Enter 4-digit PIN',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Used to secure app startup and settings.',
              style: AppTextStyles.caption.copyWith(
                color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
              ),
            ),
            const SizedBox(height: 32),

            // Obfuscated dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final hasDigit = index < currentText.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasDigit
                        ? AppColors.accent
                        : (isLight ? AppColors.border : AppColors.borderDark),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold)),

            const Spacer(),

            // Numeric Keyboard
            _buildKeyboard(isLight),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard(bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [1, 2, 3].map((val) => _keyboardButton(val, isLight)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [4, 5, 6].map((val) => _keyboardButton(val, isLight)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [7, 8, 9].map((val) => _keyboardButton(val, isLight)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _keyboardIconButton(Icons.backspace_outlined, _handleDelete, isLight),
              _keyboardButton(0, isLight),
              _keyboardIconButton(Icons.check_circle_outline, _handleNext, isLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keyboardButton(int val, bool isLight) {
    return GestureDetector(
      onTap: () => _handleNumber(val),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.surfaceDark,
          shape: BoxShape.circle,
          border: Border.all(color: isLight ? AppColors.border : AppColors.borderDark),
        ),
        child: Center(
          child: Text(
            val.toString(),
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _keyboardIconButton(IconData icon, VoidCallback onTap, bool isLight) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.surfaceDark,
          shape: BoxShape.circle,
          border: Border.all(color: isLight ? AppColors.border : AppColors.borderDark),
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }
}

class LockScreenOverlay extends ConsumerStatefulWidget {
  const LockScreenOverlay({super.key});

  @override
  ConsumerState<LockScreenOverlay> createState() => _LockScreenOverlayState();
}

class _LockScreenOverlayState extends ConsumerState<LockScreenOverlay> {
  String _pin = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    // Auto trigger biometric scan on overlay mount if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerBiometric();
    });
  }

  Future<void> _triggerBiometric() async {
    final notifier = ref.read(securityViewModelProvider.notifier);
    final state = ref.read(securityViewModelProvider);
    if (state.biometricEnabled) {
      await notifier.authenticateWithBiometric();
    }
  }

  void _handleNumber(int val) async {
    setState(() {
      _error = null;
      if (_pin.length < 4) _pin += val.toString();
    });

    if (_pin.length == 4) {
      final success = await ref.read(securityViewModelProvider.notifier).verifyAndUnlock(_pin);
      if (!success) {
        setState(() {
          _pin = '';
          _error = 'Incorrect passcode PIN. Please try again.';
        });
      }
    }
  }

  void _handleDelete() {
    setState(() {
      if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  void _handleForgotPin() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isLight ? Colors.white : AppColors.surfaceDark,
          title: const Text('Reset PIN Lock?'),
          content: const Text(
            'To reset your PIN, you will be signed out of your account. You will need to log back in using your email credentials to setup a new passcode PIN.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final authViewModel = ref.read(authViewModelProvider.notifier);
                await ref.read(securityViewModelProvider.notifier).logoutAllDevices(authViewModel);
                if (context.mounted) {
                  Navigator.pop(context);
                  context.go('/login');
                }
              },
              child: const Text('Reset & Sign Out', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final state = ref.watch(securityViewModelProvider);

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Logo / Title
            const Text('🔐', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'MiGoalPilot Locked',
              style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your 4-digit passcode PIN to unlock.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
              ),
            ),
            const Spacer(flex: 1),

            // Obfuscated dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final hasDigit = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasDigit
                        ? AppColors.accent
                        : (isLight ? AppColors.border : AppColors.borderDark),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold)),

            const Spacer(flex: 2),

            // Numeric Keyboard
            _buildKeyboard(isLight, state.biometricEnabled),
            const SizedBox(height: 16),

            // Forgot PIN
            TextButton(
              onPressed: _handleForgotPin,
              child: Text(
                'Forgot PIN?',
                style: TextStyle(
                  color: isLight ? AppColors.primary : AppColors.accentDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard(bool isLight, bool biometricEnabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [1, 2, 3].map((val) => _keyboardButton(val, isLight)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [4, 5, 6].map((val) => _keyboardButton(val, isLight)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [7, 8, 9].map((val) => _keyboardButton(val, isLight)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              biometricEnabled
                  ? _keyboardIconButton(Icons.fingerprint_rounded, _triggerBiometric, isLight)
                  : const SizedBox(width: 64, height: 64),
              _keyboardButton(0, isLight),
              _keyboardIconButton(Icons.backspace_outlined, _handleDelete, isLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keyboardButton(int val, bool isLight) {
    return GestureDetector(
      onTap: () => _handleNumber(val),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.surfaceDark,
          shape: BoxShape.circle,
          border: Border.all(color: isLight ? AppColors.border : AppColors.borderDark),
        ),
        child: Center(
          child: Text(
            val.toString(),
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _keyboardIconButton(IconData icon, VoidCallback onTap, bool isLight) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.surfaceDark,
          shape: BoxShape.circle,
          border: Border.all(color: isLight ? AppColors.border : AppColors.borderDark),
        ),
        child: Icon(icon, size: 22, color: AppColors.accent),
      ),
    );
  }
}

class SessionManagementScreen extends ConsumerWidget {
  const SessionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(securityViewModelProvider);
    final notifier = ref.read(securityViewModelProvider.notifier);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Active Sessions',
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: state.isSessionSupported
              ? _buildSessionList(context, state, notifier, isLight)
              : _buildUnsupportedCard(isLight),
        ),
      ),
    );
  }

  Widget _buildUnsupportedCard(bool isLight) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isLight ? AppColors.border : AppColors.borderDark),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚫', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 16),
            const Text(
              'Session Management Unavailable',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'This server configuration does not support device session management. All tokens are encrypted and preserved securely on this local device keychain.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList(BuildContext context, SecurityState state, SecurityViewModel notifier, bool isLight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Linked Devices & Sessions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Below are active access sessions authenticated under your account credentials.',
          style: TextStyle(
            fontSize: 12,
            color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: state.activeSessions.length,
            itemBuilder: (context, index) {
              final s = state.activeSessions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isLight ? AppColors.border : AppColors.borderDark),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.deviceType,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.lastActiveDescription,
                          style: TextStyle(
                            fontSize: 11,
                            color: s.isActiveNow ? AppColors.accent : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (!s.isActiveNow)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        onPressed: () => notifier.revokeSession(s.id),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
