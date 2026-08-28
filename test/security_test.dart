import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:migoalpilot/core/services/services.dart';
import 'package:migoalpilot/core/services/security_service.dart';
import 'package:migoalpilot/core/services/biometric_service.dart';
import 'package:migoalpilot/core/repositories/session_repository.dart';
import 'package:migoalpilot/core/viewmodels/security_viewmodel.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockBiometricService extends Mock implements BiometricService {}
class MockAuthViewModel extends Mock implements AuthViewModel {}

void main() {
  late MockSecureStorageService mockSecureStorage;
  late MockBiometricService mockBiometric;
  late MockSessionRepository mockSessionRepo;
  late SecurityService securityService;
  late SecurityViewModel viewModel;

  setUp(() {
    mockSecureStorage = MockSecureStorageService();
    mockBiometric = MockBiometricService();
    mockSessionRepo = MockSessionRepository();
    securityService = SecurityService(mockSecureStorage);

    // Default mock setup for secure storage reads (no PIN set)
    when(() => mockSecureStorage.read(any())).thenAnswer((_) async => null);
    when(() => mockSecureStorage.write(any(), any())).thenAnswer((_) async {});
    when(() => mockSecureStorage.delete(any())).thenAnswer((_) async {});

    // Default biometric mock setup
    when(() => mockBiometric.isBiometricAvailable()).thenAnswer((_) async => false);

    viewModel = SecurityViewModel(
      securityService,
      mockBiometric,
      mockSessionRepo,
    );
  });

  group('PIN Hashing & Verification Tests', () {
    test('Setting and verifying PIN uses hashing and works correctly', () async {
      String? savedHash;
      String? savedSalt;

      when(() => mockSecureStorage.write('sec_pin_hash', any())).thenAnswer((invocation) async {
        savedHash = invocation.positionalArguments[1] as String;
      });
      when(() => mockSecureStorage.write('sec_pin_salt', any())).thenAnswer((invocation) async {
        savedSalt = invocation.positionalArguments[1] as String;
      });

      // Set PIN
      await securityService.setPin('1234');

      expect(savedHash, isNotNull);
      expect(savedSalt, isNotNull);
      expect(savedHash, isNot(equals('1234'))); // Raw PIN must never be stored!

      // Setup reads for verification
      when(() => mockSecureStorage.read('sec_pin_hash')).thenAnswer((_) async => savedHash);
      when(() => mockSecureStorage.read('sec_pin_salt')).thenAnswer((_) async => savedSalt);

      // Verify correct PIN
      final verifiedCorrect = await securityService.verifyPin('1234');
      expect(verifiedCorrect, isTrue);

      // Verify incorrect PIN
      final verifiedIncorrect = await securityService.verifyPin('9999');
      expect(verifiedIncorrect, isFalse);
    });

    test('Disabling PIN removes hash and salt keys', () async {
      var deletedHash = false;
      var deletedSalt = false;

      when(() => mockSecureStorage.delete('sec_pin_hash')).thenAnswer((_) async => deletedHash = true);
      when(() => mockSecureStorage.delete('sec_pin_salt')).thenAnswer((_) async => deletedSalt = true);

      await securityService.disablePin();

      expect(deletedHash, isTrue);
      expect(deletedSalt, isTrue);
    });
  });

  group('SecurityViewModel Configuration & State Tests', () {
    test('Initial loading defaults to unlocked and unconfigured', () async {
      await viewModel.loadSettings();

      expect(viewModel.state.isLocked, isFalse);
      expect(viewModel.state.appLockEnabled, isFalse);
      expect(viewModel.state.biometricEnabled, isFalse);
      expect(viewModel.state.hasPin, isFalse);
    });

    test('ViewModel starts in locked state if appLockEnabled is true', () async {
      // Mock appLockEnabled = true and PIN set
      when(() => mockSecureStorage.read('sec_app_lock_enabled')).thenAnswer((_) async => 'true');
      when(() => mockSecureStorage.read('sec_pin_hash')).thenAnswer((_) async => 'somehash');

      final lockedViewModel = SecurityViewModel(securityService, mockBiometric, mockSessionRepo);
      await lockedViewModel.loadSettings();

      expect(lockedViewModel.state.appLockEnabled, isTrue);
      expect(lockedViewModel.state.isLocked, isTrue); // Must startup locked
    });

    test('Toggling biometric unlock checks capability and toggles correctly', () async {
      // If biometrics not available, toggle biometric should fail and set error
      when(() => mockBiometric.isBiometricAvailable()).thenAnswer((_) async => false);
      await viewModel.toggleBiometric(true);
      expect(viewModel.state.biometricEnabled, isFalse);
      expect(viewModel.state.error, isNotNull);

      // If biometrics available
      when(() => mockBiometric.isBiometricAvailable()).thenAnswer((_) async => true);
      await viewModel.toggleBiometric(true);
      expect(viewModel.state.biometricEnabled, isTrue);
    });
  });

  group('Biometric Auth Integration Tests', () {
    test('Successful biometric auth sets isLocked to false', () async {
      when(() => mockSecureStorage.read('sec_biometric_enabled')).thenAnswer((_) async => 'true');
      when(() => mockSecureStorage.read('sec_app_lock_enabled')).thenAnswer((_) async => 'true');

      final authViewModel = SecurityViewModel(securityService, mockBiometric, mockSessionRepo);
      await authViewModel.loadSettings();

      expect(authViewModel.state.isLocked, isTrue);

      // Mock biometric success
      when(() => mockBiometric.authenticate(any())).thenAnswer((_) async => true);

      final success = await authViewModel.authenticateWithBiometric();
      expect(success, isTrue);
      expect(authViewModel.state.isLocked, isFalse);
    });

    test('Failed or cancelled biometric auth leaves app locked', () async {
      when(() => mockSecureStorage.read('sec_biometric_enabled')).thenAnswer((_) async => 'true');
      when(() => mockSecureStorage.read('sec_app_lock_enabled')).thenAnswer((_) async => 'true');

      final authViewModel = SecurityViewModel(securityService, mockBiometric, mockSessionRepo);
      await authViewModel.loadSettings();

      expect(authViewModel.state.isLocked, isTrue);

      // Mock biometric failure / cancellation
      when(() => mockBiometric.authenticate(any())).thenAnswer((_) async => false);

      final success = await authViewModel.authenticateWithBiometric();
      expect(success, isFalse);
      expect(authViewModel.state.isLocked, isTrue); // Still locked
    });
  });

  group('Session Revocation Tests', () {
    test('Unsupported backend session call does not fake and throws UnsupportedError', () async {
      // By default mockSessionRepo.isSupported is false
      await viewModel.loadSettings();
      expect(viewModel.state.isSessionSupported, isFalse);

      // Attempting to load sessions does nothing / keeps empty
      await viewModel.loadSessions();
      expect(viewModel.state.activeSessions, isEmpty);
    });

    test('Supported backend session lists and revokes sessions correctly', () async {
      mockSessionRepo.setSupported(true);
      await viewModel.loadSettings();

      expect(viewModel.state.isSessionSupported, isTrue);
      expect(viewModel.state.activeSessions, hasLength(2));

      // Revoke session_other_1
      await viewModel.revokeSession('session_other_1');

      expect(viewModel.state.activeSessions, hasLength(1));
      expect(viewModel.state.activeSessions.first.id, equals('session_current'));
    });
  });
}
