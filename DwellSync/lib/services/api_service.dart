import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      // Use localhost for web development, since the backend runs locally on port 5000.
      if (host.isEmpty || host == 'localhost' || host == '127.0.0.1') {
        return 'http://localhost:5000/api';
      }
      final scheme = Uri.base.scheme == 'https' ? 'http' : Uri.base.scheme;
      return '$scheme://$host:5000/api';
    }
    // For Android emulator use 10.0.2.2 to reach host machine.
    // For physical devices or desktop, update this to your machine IP if needed.
    return 'http://10.0.2.2:5000/api';
  }

  // For local development on emulator, use: http://10.0.2.2:5000/api
  // For physical device, use your machine's IP address
  
  static String? _token;

  // ============ INITIALIZATION ============
  
  static Future<void> initToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('DwellSync_token');
    } catch (e) {
      // ignore: avoid_print
      print('Error initializing token: $e');
    }
  }

  static Future<void> saveToken(String token) async {
    try {
      _token = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('DwellSync_token', token);
    } catch (e) {
      // ignore: avoid_print
      print('Error saving token: $e');
    }
  }

  static Future<void> clearToken() async {
    try {
      _token = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('DwellSync_token');
    } catch (e) {
      // ignore: avoid_print
      print('Error clearing token: $e');
    }
  }

  // ============ HELPER METHODS ============

  static Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static String? get token => _token;

  // ============ AUTH ENDPOINTS ============

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    String? inviteCode,
    String? photoUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
          if (inviteCode != null && inviteCode.isNotEmpty) 'inviteCode': inviteCode,
          if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch user'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    XFile? photoFile,
  }) async {
    try {
      if (photoFile != null) {
        final uri = Uri.parse('$baseUrl/auth/me');
        final request = http.MultipartRequest('PUT', uri);
        final headers = _getHeaders();
        headers.remove('Content-Type');
        request.headers.addAll(headers);
        if (name != null) request.fields['name'] = name;
        if (phone != null) request.fields['phone'] = phone;
        final bytes = await photoFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: photoFile.name,
        ));
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return {'success': true, 'data': data};
        } else {
          final data = jsonDecode(response.body);
          return {'success': false, 'message': data['message']};
        }
      }

      final response = await http.put(
        Uri.parse('$baseUrl/auth/me'),
        headers: _getHeaders(),
        body: jsonEncode({
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getTenants() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/tenants'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch tenants'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============ BILL ENDPOINTS ============

  static Future<Map<String, dynamic>> createBill({
    required String tenantId,
    required double rentAmount,
    required double electricityBill,
    required double waterBill,
    required double gasBill,
    required DateTime dueDate,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bills'),
        headers: _getHeaders(),
        body: jsonEncode({
          'tenantId': tenantId,
          'rentAmount': rentAmount,
          'electricityBill': electricityBill,
          'waterBill': waterBill,
          'gasBill': gasBill,
          'dueDate': dueDate.toIso8601String(),
          'notes': notes ?? '',
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getBills() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bills'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch bills'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getBill(String billId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bills/$billId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch bill'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateBill({
    required String billId,
    double? rentAmount,
    double? electricityBill,
    double? waterBill,
    double? gasBill,
    DateTime? dueDate,
    String? status,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (rentAmount != null) body['rentAmount'] = rentAmount;
      if (electricityBill != null) body['electricityBill'] = electricityBill;
      if (waterBill != null) body['waterBill'] = waterBill;
      if (gasBill != null) body['gasBill'] = gasBill;
      if (dueDate != null) body['dueDate'] = dueDate.toIso8601String();
      if (status != null) body['status'] = status;
      if (notes != null) body['notes'] = notes;

      final response = await http.put(
        Uri.parse('$baseUrl/bills/$billId'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteBill(String billId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/bills/$billId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getTenantBills(String tenantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bills/tenant/$tenantId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch tenant bills'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============ PAYMENT ENDPOINTS ============

  static Future<Map<String, dynamic>> createPayment({
    required String billId,
    required double amount,
    String? paymentMethod,
    String? transactionId,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: _getHeaders(),
        body: jsonEncode({
          'billId': billId,
          'amount': amount,
          'paymentMethod': paymentMethod ?? 'bank_transfer',
          'transactionId': transactionId ?? '',
          'notes': notes ?? '',
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPayments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch payments'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getBillPayments(String billId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/bill/$billId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch bill payments'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============ MESSAGE ENDPOINTS ============

  static Future<Map<String, dynamic>> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: _getHeaders(),
        body: jsonEncode({
          'receiverId': receiverId,
          'text': text,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed to send message'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch messages'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
