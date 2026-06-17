import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dwell_sync/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final List<User> _users = [];
  User? _currentUser;
  bool _isLoading = false;
  bool _initialized = false;

  // Getters
  List<User> get allUsers => _users;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get initialized => _initialized;

  AuthProvider() {
    _loadFromStorage();
    _initialized = true;
  }

  // ============ STORAGE ============

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load all users
      final usersJson = prefs.getString('DwellSync_users');
      if (usersJson != null) {
        final list = jsonDecode(usersJson) as List;
        _users.clear();
        _users.addAll(list.map((e) => User.fromJson(e as Map<String, dynamic>)));
      }

      // Load current user
      final currentUserJson = prefs.getString('DwellSync_currentUser');
      if (currentUserJson != null) {
        _currentUser = User.fromJson(jsonDecode(currentUserJson));
      }

      notifyListeners();
    } catch (e) {
      print('Error loading from storage: $e');
    }
  }

  Future<void> _saveUsersLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_users.map((u) => u.toJson()).toList());
      await prefs.setString('DwellSync_users', jsonStr);
    } catch (e) {
      print('Error saving users: $e');
    }
  }

  Future<void> _saveCurrentUserLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString('DwellSync_currentUser', jsonEncode(_currentUser!.toJson()));
      } else {
        await prefs.remove('DwellSync_currentUser');
      }
    } catch (e) {
      print('Error saving current user: $e');
    }
  }

  // ============ REGISTRATION ============

  Future<User> registerLandlord({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final normalizedEmail = email.trim().toLowerCase();
      
      // Check if email already exists
      final existing = _users.firstWhere(
        (u) => u.email.toLowerCase() == normalizedEmail,
        orElse: () => User(
          id: '',
          email: '',
          name: '',
          phone: '',
          role: 'none',
          createdAt: DateTime.now(),
        ),
      );
      
      if (existing.id.isNotEmpty) {
        throw Exception('Email already registered');
      }

      final id = 'landlord_${DateTime.now().millisecondsSinceEpoch}';
      final code = _generateInviteCode();
      final user = User(
        id: id,
        name: name,
        email: normalizedEmail,
        phone: phone,
        role: 'landlord',
        inviteCode: code,
        isVerified: true,
        password: password,
        createdAt: DateTime.now(),
      );

      _users.add(user);
      await _saveUsersLocally();
      _isLoading = false;
      notifyListeners();

      return user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
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

    try {
      // Verify invite code
      final landlord = _users.firstWhere(
        (u) => u.id == landlordId && u.inviteCode == inviteCode,
        orElse: () => User(
          id: '',
          email: '',
          name: '',
          phone: '',
          role: 'none',
          createdAt: DateTime.now(),
        ),
      );

      if (landlord.id.isEmpty) {
        throw Exception('Invalid invite code');
      }

      final normalizedEmail = email.trim().toLowerCase();
      final existing = _users.firstWhere(
        (u) => u.email.toLowerCase() == normalizedEmail,
        orElse: () => User(
          id: '',
          email: '',
          name: '',
          phone: '',
          role: 'none',
          createdAt: DateTime.now(),
        ),
      );

      if (existing.id.isNotEmpty) {
        throw Exception('Email already registered');
      }

      final id = 'tenant_${DateTime.now().millisecondsSinceEpoch}';
      final user = User(
        id: id,
        name: name,
        email: normalizedEmail,
        phone: phone,
        role: 'tenant',
        landlordId: landlordId,
        isVerified: true,
        password: password,
        createdAt: DateTime.now(),
      );

      _users.add(user);
      await _saveUsersLocally();
      _isLoading = false;
      notifyListeners();

      return user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ============ AUTHENTICATION ============

  Future<User> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final normalizedEmail = email.trim().toLowerCase();

      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == normalizedEmail && u.password == password,
        orElse: () => User(
          id: '',
          email: '',
          name: '',
          phone: '',
          role: 'none',
          createdAt: DateTime.now(),
        ),
      );

      if (user.id.isEmpty) {
        throw Exception('Invalid email or password');
      }

      _currentUser = user;
      await _saveCurrentUserLocally();
      _isLoading = false;
      notifyListeners();

      return user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _saveCurrentUserLocally();
    notifyListeners();
  }

  // ============ INVITE CODE MANAGEMENT ============

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[(DateTime.now().millisecondsSinceEpoch + i) % chars.length];
    }
    return code;
  }

  Future<String> regenerateInviteCode(String landlordId) async {
    final idx = _users.indexWhere((u) => u.id == landlordId && u.role == 'landlord');
    if (idx == -1) throw Exception('Landlord not found');

    final newCode = _generateInviteCode();
    final updated = User(
      id: _users[idx].id,
      email: _users[idx].email,
      name: _users[idx].name,
      phone: _users[idx].phone,
      role: _users[idx].role,
      inviteCode: newCode,
      isVerified: _users[idx].isVerified,
      password: _users[idx].password,
      createdAt: _users[idx].createdAt,
      landlordId: _users[idx].landlordId,
    );

    _users[idx] = updated;
    await _saveUsersLocally();
    notifyListeners();
    return newCode;
  }

  // ============ USER QUERIES ============

  User? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  List<User> getTenantsForLandlord(String landlordId) {
    return _users.where((u) => u.role == 'tenant' && u.landlordId == landlordId).toList();
  }

  int getActiveTenantCount(String landlordId) {
    return getTenantsForLandlord(landlordId).length;
  }

  // ============ REFRESH ============

  Future<void> refresh() async {
    await _loadFromStorage();
  }
}
