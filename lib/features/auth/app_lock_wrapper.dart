import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/viewmodels/security_viewmodel.dart';
import 'package:migoalpilot/features/security/presentation/screens/security_views.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';

class AppLockWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const AppLockWrapper({super.key, required this.child});

  @override
  ConsumerState<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends ConsumerState<AppLockWrapper> with WidgetsBindingObserver {
  DateTime _lastActiveTime = DateTime.now();
  DateTime _lastInteractionTime = DateTime.now();
  Timer? _inactivityTimer;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;
  static const _channel = MethodChannel('com.migoalpilot.app/security');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startInactivityTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      final secState = ref.read(securityViewModelProvider);
      if (!secState.appLockEnabled || secState.isLocked) return;

      final inactivityLimit = secState.inactivityDuration;
      if (inactivityLimit > 0) {
        final elapsed = DateTime.now().difference(_lastInteractionTime).inSeconds;
        if (elapsed >= inactivityLimit) {
          ref.read(securityViewModelProvider.notifier).setLockedState(true);
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lifecycleState = state;
    });

    final secNotifier = ref.read(securityViewModelProvider.notifier);
    final secState = ref.read(securityViewModelProvider);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _lastActiveTime = DateTime.now();
      // Enable screen protection (hides content from app switcher)
      _setScreenProtection(true);
    } else if (state == AppLifecycleState.resumed) {
      // Disable screen protection when app is active
      _setScreenProtection(false);
      _lastInteractionTime = DateTime.now();

      if (secState.appLockEnabled && !secState.isLocked) {
        final inactivityLimit = secState.inactivityDuration;
        final elapsed = DateTime.now().difference(_lastActiveTime).inSeconds;

        if (inactivityLimit == 0 || elapsed >= inactivityLimit) {
          secNotifier.setLockedState(true);
        }
      }
    }
  }

  Future<void> _setScreenProtection(bool enabled) async {
    try {
      await _channel.invokeMethod('setScreenProtection', {'enabled': enabled});
    } catch (_) {
      // Gracefully catch platform exceptions (e.g. in tests/non-supported hosts)
    }
  }

  void _handleInteraction() {
    _lastInteractionTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final secState = ref.watch(securityViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final isLoggedIn = authState.user != null;

    // If locked and logged in, show the full-screen LockScreen overlay
    if (secState.isLocked && isLoggedIn) {
      return const LockScreenOverlay();
    }

    // Mask layout when application is backgrounded/inactive
    if (_lifecycleState == AppLifecycleState.inactive || _lifecycleState == AppLifecycleState.paused) {
      return Container(
        color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handleInteraction(),
      child: widget.child,
    );
  }
}
