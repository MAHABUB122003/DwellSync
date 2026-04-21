import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? inviteCode;
  final String? landlordId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.inviteCode,
    this.landlordId,
  });
}

class AuthProvider extends ChangeNotifier {
  List<User> _users = [];
  User? _currentUser;
  bool _isLoading = false;

  List<User> get allUsers => _users;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadMockUsers();
  }

  void _loadMockUsers() {
    _users = [
      User(
        id: '1',
        name: 'John Landlord',
        email: 'landlord@example.com',
        phone: '+1234567890',
        role: 'landlord',
        inviteCode: 'DWELL123',
      ),
    ];
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final user = _users.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('Invalid email or password'),
    );

    if (password.length < 6) {
      throw Exception('Invalid password');
    }

    _currentUser = user;
    _isLoading = false;
    notifyListeners();
  }

  Future<User> registerLandlord({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (_users.any((u) => u.email == email)) {
      throw Exception('Email already registered');
    }

    final inviteCode = _generateInviteCode();
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      role: 'landlord',
      inviteCode: inviteCode,
    );

    _users.add(newUser);
    _isLoading = false;
    notifyListeners();

    return newUser;
  }

  Future<User> registerTenantWithCode({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String inviteCode,
    required String landlordId,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (_users.any((u) => u.email == email)) {
      throw Exception('Email already registered');
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      role: 'tenant',
      inviteCode: inviteCode,
      landlordId: landlordId,
    );

    _users.add(newUser);
    _isLoading = false;
    notifyListeners();

    return newUser;
  }

  Future<String> regenerateInviteCode(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final newCode = _generateInviteCode();
      final updatedUser = User(
        id: _users[index].id,
        name: _users[index].name,
        email: _users[index].email,
        phone: _users[index].phone,
        role: _users[index].role,
        inviteCode: newCode,
        landlordId: _users[index].landlordId,
      );
      _users[index] = updatedUser;
      
      if (_currentUser?.id == userId) {
        _currentUser = updatedUser;
      }
      
      notifyListeners();
      return newCode;
    }
    throw Exception('User not found');
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String code = '';
    for (int i = 0; i < 8; i++) {
      code += chars[DateTime.now().millisecondsSinceEpoch % chars.length];
    }
    return code;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}