import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migoalpilot/core/services/services.dart';
import 'package:migoalpilot/features/security/domain/services/security_service.dart';
import 'package:migoalpilot/features/security/domain/services/biometric_service.dart';
import 'package:migoalpilot/features/security/domain/models/user_session.dart';
import 'package:migoalpilot/features/security/data/repositories/session_repository.dart';
import 'package:migoalpilot/features/security/presentation/viewmodels/security_state.dart';
import 'package:migoalpilot/features/auth/presentation/viewmodels/auth_viewmodel.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService(ref.watch(secureStorageServiceProvider));
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return MockSessionRepository();
});

class SecurityViewModel extends StateNotifier<SecurityState> {
  final SecurityService _securityService;
  final BiometricService _biometricService;
  final SessionRepository _sessionRepository;

  SecurityViewModel(
    this._securityService,
    this._biometricService,
    this._sessionRepository,
  ) : super(SecurityState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final appLock = await _securityService.isAppLockEnabled();
      final biometric = await _securityService.isBiometricEnabled();
      final hasPin = await _securityService.hasPin();
      final inactivity = await _securityService.getInactivityDuration();
      final sessionSupported = _sessionRepository.isSupported;

      List<UserSession> sessions = const [];
      if (sessionSupported) {
        sessions = await _sessionRepository.getActiveSessions();
      }

      state = SecurityState(
        isLocked: appLock, // If app lock is enabled, startup starts in locked state
        appLockEnabled: appLock,
        biometricEnabled: biometric,
        hasPin: hasPin,
        inactivityDuration: inactivity,
        activeSessions: sessions,
        isSessionSupported: sessionSupported,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleAppLock(bool enabled) async {
    state = state.copyWith(isLoading: true);
    await _securityService.setAppLockEnabled(enabled);
    state = state.copyWith(appLockEnabled: enabled, isLoading: false);
  }

  Future<void> toggleBiometric(bool enabled) async {
    state = state.copyWith(isLoading: true);
    if (enabled) {
      final available = await _biometricService.isBiometricAvailable();
      if (!available) {
        state = state.copyWith(
          isLoading: false,
          error: 'Biometric authentication is not supported or not enrolled on this device.',
        );
        return;
      }
    }
    await _securityService.setBiometricEnabled(enabled);
    state = state.copyWith(biometricEnabled: enabled, isLoading: false);
  }

  Future<void> setInactivityDuration(int seconds) async {
    await _securityService.setInactivityDuration(seconds);
    state = state.copyWith(inactivityDuration: seconds);
  }

  Future<void> setPin(String pin) async {
    state = state.copyWith(isLoading: true);
    await _securityService.setPin(pin);
    state = state.copyWith(hasPin: true, appLockEnabled: true, isLoading: false);
    await _securityService.setAppLockEnabled(true);
  }

  Future<void> disablePin() async {
    state = state.copyWith(isLoading: true);
    await _securityService.disablePin();
    state = state.copyWith(
      hasPin: false,
      appLockEnabled: false,
      biometricEnabled: false,
      isLocked: false,
      isLoading: false,
    );
  }

  Future<bool> verifyAndUnlock(String pin) async {
    final success = await _securityService.verifyPin(pin);
    if (success) {
      state = state.copyWith(isLocked: false);
    }
    return success;
  }

  Future<bool> authenticateWithBiometric() async {
    if (!state.biometricEnabled) return false;
    final success = await _biometricService.authenticate('Unlock MiGoalPilot');
    if (success) {
      state = state.copyWith(isLocked: false);
    }
    return success;
  }

  // Session Management
  Future<void> loadSessions() async {
    if (!state.isSessionSupported) return;
    state = state.copyWith(isLoading: true);
    try {
      final list = await _sessionRepository.getActiveSessions();
      state = state.copyWith(activeSessions: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> revokeSession(String sessionId) async {
    if (!state.isSessionSupported) return;
    state = state.copyWith(isLoading: true);
    try {
      await _sessionRepository.revokeSession(sessionId);
      final updated = state.activeSessions.where((s) => s.id != sessionId).toList();
      state = state.copyWith(activeSessions: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logoutAllDevices(AuthViewModel authViewModel) async {
    state = state.copyWith(isLoading: true);
    try {
      if (state.isSessionSupported) {
        await _sessionRepository.revokeAllSessions();
      }
      // Securely clear all local storage credentials
      await _securityService.disablePin();
      await authViewModel.logout();
      state = state.copyWith(activeSessions: const [], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void forceLock() {
    if (state.appLockEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }

  void setLockedState(bool locked) {
    state = state.copyWith(isLocked: locked);
  }
}

final securityViewModelProvider =
    StateNotifierProvider<SecurityViewModel, SecurityState>((ref) {
  return SecurityViewModel(
    ref.watch(securityServiceProvider),
    ref.watch(biometricServiceProvider),
    ref.watch(sessionRepositoryProvider),
  );
});
