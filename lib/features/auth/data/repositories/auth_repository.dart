import 'dart:async';
import 'dart:math';
import 'package:migoalpilot/core/models/models.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> login(String email, String password);
  Future<User> register(String name, String email, String password);
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<User> updateProfile({required String name, required String email, String? phone, String? country});
}

class MockAuthRepository implements AuthRepository {
  User? _currentUser = User(
    id: 'usr_1',
    name: 'Mugesh R',
    email: 'mugesh@example.com',
    partnerId: 'partner_1',
    phone: '+91 98765 43210',
    country: 'India',
  );

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.contains('error')) {
      throw Exception('Invalid credentials or account does not exist.');
    }
    _currentUser = User(
      id: 'usr_1',
      name: email.split('@')[0].toUpperCase(),
      email: email,
      partnerId: 'partner_1',
      phone: '+91 98765 43210',
      country: 'India',
    );
    return _currentUser!;
  }

  @override
  Future<User> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = User(
      id: 'usr_${Random().nextInt(1000)}',
      name: name,
      email: email,
      phone: '',
      country: 'India',
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<User> updateProfile({required String name, required String email, String? phone, String? country}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (_currentUser == null) {
      throw Exception('Not authenticated');
    }
    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      phone: phone,
      country: country,
    );
    return _currentUser!;
  }
}
