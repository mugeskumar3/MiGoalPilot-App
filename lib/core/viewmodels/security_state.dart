import 'package:migoalpilot/core/repositories/session_repository.dart';

class SecurityState {
  final bool isLocked;
  final bool appLockEnabled;
  final bool biometricEnabled;
  final bool hasPin;
  final int inactivityDuration; // in seconds
  final List<UserSession> activeSessions;
  final bool isSessionSupported;
  final bool isLoading;
  final String? error;

  SecurityState({
    this.isLocked = false,
    this.appLockEnabled = false,
    this.biometricEnabled = false,
    this.hasPin = false,
    this.inactivityDuration = 0,
    this.activeSessions = const [],
    this.isSessionSupported = false,
    this.isLoading = false,
    this.error,
  });

  SecurityState copyWith({
    bool? isLocked,
    bool? appLockEnabled,
    bool? biometricEnabled,
    bool? hasPin,
    int? inactivityDuration,
    List<UserSession>? activeSessions,
    bool? isSessionSupported,
    bool? isLoading,
    String? error,
  }) {
    return SecurityState(
      isLocked: isLocked ?? this.isLocked,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      hasPin: hasPin ?? this.hasPin,
      inactivityDuration: inactivityDuration ?? this.inactivityDuration,
      activeSessions: activeSessions ?? this.activeSessions,
      isSessionSupported: isSessionSupported ?? this.isSessionSupported,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
