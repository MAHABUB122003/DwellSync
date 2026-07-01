import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:dwell_sync/models/user.dart';
import 'package:dwell_sync/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final List<User> _users = [];
  User? _currentUser;
  bool _isLoading = false;
  bool _initialized = false;
  String? _errorMessage;

  // Getters
  List<User> get allUsers => _users;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get initialized => _initialized;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await ApiService.initToken();
      if (ApiService.token != null) {
        final result = await ApiService.getCurrentUser();
        if (result['success']) {
          _currentUser = User.fromJson(result['data']);
          if (_currentUser!.role == 'landlord') {
            await loadAllTenants();
          } else if (_currentUser!.role == 'tenant' && _currentUser!.landlordId != null) {
            await loadLandlordInfo(_currentUser!.landlordId!);
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Error initializing auth: $e';
    }
    _initialized = true;
    notifyListeners();
  }

  // ============ REGISTRATION ============

  Future<User> registerLandlord({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: 'landlord',
        photoUrl: photoUrl,
      );

      if (result['success']) {
        final userData = result['data']['user'];
        _currentUser = User.fromJson(userData);
        _users.add(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return _currentUser!;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        throw Exception(_errorMessage ?? 'Registration failed');
      }
    } catch (e) {
      _errorMessage = e.toString();
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
    String? photoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: 'tenant',
        inviteCode: inviteCode,
        photoUrl: photoUrl,
      );

      if (result['success']) {
        final userData = result['data']['user'];
        _currentUser = User.fromJson(userData);
        _users.add(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return _currentUser!;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        throw Exception(_errorMessage ?? 'Registration failed');
      }
    } catch (e) {
      _errorMessage = e.toString();
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
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        final userData = result['data']['user'];
        _currentUser = User.fromJson(userData);
        _isLoading = false;
        notifyListeners();

        if (_currentUser!.role == 'landlord') {
          await loadAllTenants();
        } else if (_currentUser!.role == 'tenant' && _currentUser!.landlordId != null) {
          await loadLandlordInfo(_currentUser!.landlordId!);
        }

        return _currentUser!;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        throw Exception(_errorMessage ?? 'Login failed');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _users.clear();
    await ApiService.clearToken();
    notifyListeners();
  }

  // ============ INVITE CODE MANAGEMENT ============

  Future<String> regenerateInviteCode(String landlordId) async {
    try {
      final response = await _httpPutInviteRegenerate();
      if (response['success']) {
        final newCode = response['inviteCode'];
        if (_currentUser != null) {
          _currentUser = User(
            id: _currentUser!.id,
            name: _currentUser!.name,
            email: _currentUser!.email,
            phone: _currentUser!.phone,
            role: _currentUser!.role,
            inviteCode: newCode,
            isVerified: _currentUser!.isVerified,
            createdAt: _currentUser!.createdAt,
            landlordId: _currentUser!.landlordId,
          );
        }
        notifyListeners();
        return newCode;
      } else {
        throw Exception(response['message'] ?? 'Failed to regenerate invite code');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _httpPutInviteRegenerate() async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/auth/invite/regenerate'),
        headers: {
          'Content-Type': 'application/json',
          if (ApiService.token != null) 'Authorization': 'Bearer ${ApiService.token}',
        },
      );
      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Error'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ============ USER QUERIES ============

  User? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      if (_currentUser != null && _currentUser!.id == id) return _currentUser;
      return null;
    }
  }

  List<User> getTenantsForLandlord(String landlordId) {
    return _users.where((u) => u.role == 'tenant' && u.landlordId == landlordId).toList();
  }

  int getActiveTenantCount(String landlordId) {
    return getTenantsForLandlord(landlordId).length;
  }

  Future<bool> loadAllTenants() async {
    try {
      final result = await ApiService.getTenants();
      if (result['success']) {
        _users.clear();
        final tenants = (result['data'] as List)
            .map((t) => User.fromJson(t as Map<String, dynamic>))
            .toList();
        _users.addAll(tenants);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Error loading tenants: $e';
      return false;
    }
  }

  Future<void> loadLandlordInfo(String landlordId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/auth/$landlordId'),
        headers: {
          'Content-Type': 'application/json',
          if (ApiService.token != null) 'Authorization': 'Bearer ${ApiService.token}',
        },
      );
      if (response.statusCode == 200) {
        final landlord = User.fromJson(jsonDecode(response.body));
        if (!_users.any((u) => u.id == landlord.id)) {
          _users.add(landlord);
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = 'Error loading landlord info: $e';
    }
  }

  Future<User> updateProfile({
    String? name,
    String? phone,
    XFile? photoFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.updateProfile(
        name: name,
        phone: phone,
        photoFile: photoFile,
      );

      if (result['success']) {
        final updated = User.fromJson(result['data']);
        _currentUser = updated;
        final idx = _users.indexWhere((u) => u.id == updated.id);
        if (idx != -1) {
          _users[idx] = updated;
        }
        _isLoading = false;
        notifyListeners();
        return updated;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        throw Exception(_errorMessage ?? 'Profile update failed');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refresh() async {
    if (_currentUser != null) {
      if (_currentUser!.role == 'landlord') {
        await loadAllTenants();
      } else if (_currentUser!.role == 'tenant' && _currentUser!.landlordId != null) {
        await loadLandlordInfo(_currentUser!.landlordId!);
      }
    }
  }
}
