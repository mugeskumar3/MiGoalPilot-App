class UserSession {
  final String id;
  final String deviceType;
  final bool isActiveNow;
  final String lastActiveDescription;

  UserSession({
    required this.id,
    required this.deviceType,
    required this.isActiveNow,
    required this.lastActiveDescription,
  });
}
