import 'package:migoalpilot/features/security/domain/models/user_session.dart';

abstract class SessionRepository {
  bool get isSupported;
  Future<List<UserSession>> getActiveSessions();
  Future<void> revokeSession(String sessionId);
  Future<void> revokeAllSessions();
}

class MockSessionRepository implements SessionRepository {
  // By default, the mock backend does not support session/device management
  // matching real backend limitations, but we allow changing this flag for testing.
  bool _isSupported = false;

  final List<UserSession> _sessions = [
    UserSession(
      id: 'session_current',
      deviceType: 'Android Device',
      isActiveNow: true,
      lastActiveDescription: 'Active now',
    ),
    UserSession(
      id: 'session_other_1',
      deviceType: 'Chrome Browser',
      isActiveNow: false,
      lastActiveDescription: 'Last active 2 hours ago',
    ),
  ];

  @override
  bool get isSupported => _isSupported;

  void setSupported(bool supported) {
    _isSupported = supported;
  }

  @override
  Future<List<UserSession>> getActiveSessions() async {
    if (!isSupported) {
      throw UnsupportedError('Device session management is not supported by this server configuration.');
    }
    await Future.delayed(const Duration(milliseconds: 400));
    return _sessions;
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    if (!isSupported) {
      throw UnsupportedError('Device session management is not supported by this server configuration.');
    }
    await Future.delayed(const Duration(milliseconds: 400));
    _sessions.removeWhere((s) => s.id == sessionId);
  }

  @override
  Future<void> revokeAllSessions() async {
    if (!isSupported) {
      throw UnsupportedError('Device session revocation is not supported by this server configuration.');
    }
    await Future.delayed(const Duration(milliseconds: 500));
    _sessions.clear();
  }
}
