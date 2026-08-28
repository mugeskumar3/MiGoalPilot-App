import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final isDeviceSupported = await _auth.isDeviceSupported();
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      if (!isDeviceSupported || !canAuthenticateWithBiometrics) return false;

      final enrolledBiometrics = await _auth.getAvailableBiometrics();
      return enrolledBiometrics.isNotEmpty;
    } catch (e) {
      // Do not log sensitive details, return false
      return false;
    }
  }

  Future<bool> authenticate(String reason) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (_) {
      // Handle too many failed attempts, cancelled, not enrolled, etc.
      // Retain clean and non-crashing flows.
      return false;
    } catch (e) {
      return false;
    }
  }
}
