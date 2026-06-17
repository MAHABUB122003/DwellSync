import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dwell_sync/models/bill.dart';
import 'package:dwell_sync/models/user.dart';
import 'package:dwell_sync/providers/auth_provider.dart';

/// PaymentProvider manages all payment, billing, and messaging functionality
/// Uses local storage (SharedPreferences) for persistence
class PaymentProvider with ChangeNotifier {
  // Private data storage
  final List<Bill> _bills = [];
  final List<Map<String, dynamic>> _payments = [];
  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, dynamic>> _tenants = [];
  
  bool _isLoading = false;
  static const _billsKey = 'DwellSync_bills';
  late AuthProvider _authProvider;

  // ============ GETTERS ============
  List<Bill> get bills => _bills;
  List<Map<String, dynamic>> get payments => _payments;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get tenants => _tenants;

  PaymentProvider() {
    _loadBillsFromStorage();
  }

  /// Initialize with AuthProvider reference
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    _updateRealTenants();
  }

  // ============ TENANT MANAGEMENT ============

  void _updateRealTenants() {
    try {
      final realTenants = _authProvider.allUsers
          .where((user) => user.role == 'tenant')
          .map((user) => {
                'id': user.id,
                'name': user.name,
                'email': user.email,
                'phone': user.phone,
                'landlordId': user.landlordId,
                'active': true,
                'monthlyRent': 15000.0,
                'notices': <Map<String, dynamic>>[],
              })
          .toList();

      _tenants.clear();
      _tenants.addAll(realTenants);
      print('Updated tenants list: ${_tenants.length} real tenants loaded');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('Error updating real tenants: $e');
    }
  }

  void addTenantFromUser(User user) {
    if (user.role == 'tenant') {
      final existingIndex = _tenants.indexWhere((t) => t['id'] == user.id);
      if (existingIndex == -1) {
        _tenants.add({
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'landlordId': user.landlordId,
          'active': true,
          'monthlyRent': 15000.0,
          'notices': <Map<String, dynamic>>[],
        });
        print('Tenant added: ${user.name}');
        notifyListeners();
      }
    }
  }

  void sendNoticeToTenant(String tenantId, String message) {
    final idx = _tenants.indexWhere((t) => t['id'] == tenantId);
    if (idx != -1) {
      final notice = {
        'id': 'notice_${DateTime.now().millisecondsSinceEpoch}',
        'message': message,
        'date': DateTime.now(),
        'read': false,
      };
      final notices = _tenants[idx]['notices'] as List<dynamic>? ?? [];
      notices.insert(0, notice);
      _tenants[idx]['notices'] = notices;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getNoticesForTenant(String tenantId) {
    final t = _tenants.firstWhere((e) => e['id'] == tenantId, orElse: () => {});
    if (t.isEmpty) return [];
    final notices = (t['notices'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    return notices;
  }

  void updateTenantRent(String tenantId, double monthlyRent) {
    final idx = _tenants.indexWhere((t) => t['id'] == tenantId);
    if (idx != -1) {
      _tenants[idx]['monthlyRent'] = monthlyRent;
      notifyListeners();
    }
  }

  // ============ STORAGE OPERATIONS ============

  Future<void> _loadBillsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final billsJson = prefs.getString(_billsKey);
      if (billsJson != null) {
        final list = jsonDecode(billsJson) as List;
        _bills.addAll(list.map((e) => Bill.fromJson(e as Map<String, dynamic>)));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading bills from storage: $e');
    }
  }

  Future<void> _saveBillsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(_bills.map((b) => b.toJson()).toList());
      await prefs.setString(_billsKey, jsonStr);
    } catch (e) {
      print('Error saving bills to storage: $e');
    }
  }

  // ============ BILL OPERATIONS ============

  Future<void> createBill({
    required String tenantId,
    required String landlordId,
    required double rentAmount,
    required double electricityBill,
    required double waterBill,
    required double gasBill,
    required DateTime dueDate,
  }) async {
    final totalAmount = rentAmount + electricityBill + waterBill + gasBill;

    final newBill = Bill(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      landlordId: landlordId,
      rentAmount: rentAmount,
      electricityBill: electricityBill,
      waterBill: waterBill,
      gasBill: gasBill,
      totalAmount: totalAmount,
      dueDate: dueDate,
      billDate: DateTime.now(),
      status: 'pending',
    );

    try {
      _bills.insert(0, newBill);
      await _saveBillsToStorage();
      notifyListeners();
    } catch (e) {
      print('Error creating bill: $e');
      rethrow;
    }
  }

  Future<void> makePayment(String billId, String method, String transactionId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final index = _bills.indexWhere((bill) => bill.id == billId);
    if (index != -1) {
      final updatedBill = Bill(
        id: _bills[index].id,
        tenantId: _bills[index].tenantId,
        landlordId: _bills[index].landlordId,
        rentAmount: _bills[index].rentAmount,
        electricityBill: _bills[index].electricityBill,
        waterBill: _bills[index].waterBill,
        gasBill: _bills[index].gasBill,
        totalAmount: _bills[index].totalAmount,
        dueDate: _bills[index].dueDate,
        billDate: _bills[index].billDate,
        status: 'paid',
        paidDate: DateTime.now(),
      );

      final payment = {
        'id': 'payment_${DateTime.now().millisecondsSinceEpoch}',
        'billId': billId,
        'tenantId': _bills[index].tenantId,
        'landlordId': _bills[index].landlordId,
        'amount': _bills[index].totalAmount,
        'date': DateTime.now(),
        'method': method,
        'status': 'success',
        'transactionId': transactionId,
      };

      _bills[index] = updatedBill;
      _payments.insert(0, payment);
      await _saveBillsToStorage();
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============ BILL QUERIES - TENANT ============

  List<Bill> getBillsForTenant(String tenantId) {
    return _bills.where((bill) => bill.tenantId == tenantId).toList();
  }

  List<Bill> getBillsForTenantId(String tenantId) {
    return _bills.where((bill) => bill.tenantId == tenantId).toList();
  }

  List<Bill> getPendingBillsForSpecificTenant(String tenantId) {
    return _bills
        .where((bill) => bill.tenantId == tenantId && bill.status == 'pending')
        .toList();
  }

  List<Bill> getPaidBillsForSpecificTenant(String tenantId) {
    return _bills
        .where((bill) => bill.tenantId == tenantId && bill.status == 'paid')
        .toList();
  }

  double getTotalPendingAmountForTenant(String tenantId) {
    return getPendingBillsForSpecificTenant(tenantId)
        .fold(0.0, (sum, bill) => sum + bill.totalAmount);
  }

  List<Map<String, dynamic>> getPaymentsForTenantId(String tenantId) {
    return _payments.where((payment) => payment['tenantId'] == tenantId).toList();
  }

  // ============ BILL QUERIES - LANDLORD ============

  List<Bill> getBillsForLandlord(String landlordId) {
    return _bills.where((bill) => bill.landlordId == landlordId).toList();
  }

  List<Bill> getPendingBillsForLandlord(String landlordId) {
    return _bills
        .where((bill) =>
            bill.landlordId == landlordId && bill.status == 'pending')
        .toList();
  }

  int getActiveTenantsCountForLandlord(String landlordId) {
    return _tenants
        .where((tenant) =>
            tenant['landlordId'] == landlordId && tenant['active'] == true)
        .length;
  }

  double getTotalCollectedForLandlord(String landlordId) {
    final paidBills = _bills
        .where((bill) => bill.landlordId == landlordId && bill.status == 'paid')
        .toList();
    return paidBills.fold(0.0, (sum, bill) => sum + bill.totalAmount);
  }

  int getTotalPaidBillsCount() {
    return _bills.where((bill) => bill.status == 'paid').length;
  }

  int getTotalPaidBillsCountForLandlord(String landlordId) {
    return _bills
        .where((bill) => bill.landlordId == landlordId && bill.status == 'paid')
        .length;
  }

  List<Map<String, dynamic>> getRecentPaidBillsForLandlord(String landlordId) {
    final paidBills =
        _bills.where((bill) => bill.landlordId == landlordId && bill.status == 'paid').toList();

    final billsWithDetails = paidBills.map((bill) {
      final tenant = _authProvider.allUsers.firstWhere(
        (user) => user.id == bill.tenantId,
        orElse: () => User(
          id: '',
          email: '',
          name: 'Unknown Tenant',
          phone: '',
          role: 'tenant',
          createdAt: DateTime.now(),
        ),
      );
      return {
        'bill': bill,
        'tenantName': tenant.name,
        'tenantEmail': tenant.email,
        'tenantId': bill.tenantId,
        'amount': bill.totalAmount,
        'paidDate': bill.paidDate ?? DateTime.now(),
      };
    }).toList();

    billsWithDetails.sort((a, b) =>
        (b['paidDate'] as DateTime).compareTo(a['paidDate'] as DateTime));
    return billsWithDetails.take(5).toList();
  }

  // ============ MESSAGING ============

  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    final msg = {
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'date': DateTime.now(),
    };
    _messages.insert(0, msg);
    notifyListeners();
  }

  List<Map<String, dynamic>> getMessagesBetween(String aId, String bId) {
    final list = _messages.where((m) {
      final s = m['senderId'] as String? ?? '';
      final r = m['receiverId'] as String? ?? '';
      return (s == aId && r == bId) || (s == bId && r == aId);
    }).toList();

    // sort ascending by date (oldest first)
    list.sort((x, y) {
      final dx = x['date'] as DateTime? ?? DateTime.now();
      final dy = y['date'] as DateTime? ?? DateTime.now();
      return dx.compareTo(dy);
    });
    return list;
  }

  List<Map<String, dynamic>> getConversationsFor(String userId) {
    final partners = <String, Map<String, dynamic>>{};
    for (final m in _messages) {
      final s = m['senderId'] as String? ?? '';
      final r = m['receiverId'] as String? ?? '';
      final other = s == userId ? r : (r == userId ? s : null);
      if (other == null) continue;
      if (!partners.containsKey(other)) {
        partners[other] = m;
      }
    }

    final list = partners.entries
        .map((e) => {'partnerId': e.key, 'lastMessage': e.value})
        .toList();

    // sort by last message date descending (most recent first)
    list.sort((a, b) {
      final da =
          (a['lastMessage'] as Map<String, dynamic>)['date'] as DateTime? ??
              DateTime.now();
      final db =
          (b['lastMessage'] as Map<String, dynamic>)['date'] as DateTime? ??
              DateTime.now();
      return db.compareTo(da);
    });
    return list;
  }

  // ============ NOTIFICATIONS ============

  Future<bool> sendReminder(String tenantId, String message) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
