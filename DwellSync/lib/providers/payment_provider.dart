import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:dwell_sync/models/bill.dart';
import 'package:dwell_sync/models/user.dart';
import 'package:dwell_sync/providers/auth_provider.dart';
import 'package:dwell_sync/services/api_service.dart';

class PaymentProvider with ChangeNotifier {
  final List<Bill> _bills = [];
  final List<Map<String, dynamic>> _payments = [];
  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, dynamic>> _tenants = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  late AuthProvider _authProvider;
  String? _lastLoadedUserId;

  // ============ GETTERS ============
  List<Bill> get bills => _bills;
  List<Map<String, dynamic>> get payments => _payments;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get tenants => _tenants;
  String? get errorMessage => _errorMessage;

  PaymentProvider();

  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    
    final currentUserId = authProvider.currentUser?.id;
    if (currentUserId != _lastLoadedUserId) {
      _lastLoadedUserId = currentUserId;
      if (currentUserId != null) {
        _loadDataFromBackend();
      } else {
        _bills.clear();
        _payments.clear();
        _messages.clear();
        _tenants.clear();
        notifyListeners();
      }
    } else if (currentUserId != null && _tenants.isEmpty && authProvider.allUsers.isNotEmpty) {
      _updateRealTenants();
    }
  }

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

  // ============ BACKEND OPERATIONS ============

  Future<void> _loadDataFromBackend() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadBillsFromBackend();
      await loadPayments();
      await loadMessages();
      
      if (_authProvider.currentUser?.role == 'landlord') {
        await _authProvider.loadAllTenants();
        _updateRealTenants();
      }
    } catch (e) {
      print('Error loading initial data from backend: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadBillsFromBackend() async {
    try {
      final result = await ApiService.getBills();
      if (result['success']) {
        _bills.clear();
        final billsList = (result['data'] as List)
            .map((b) => Bill.fromJson(b as Map<String, dynamic>))
            .toList();
        _bills.addAll(billsList);
      }
    } catch (e) {
      print('Error loading bills: $e');
    }
  }

  Future<void> createBill({
    required String tenantId,
    required String landlordId,
    required double rentAmount,
    required double electricityBill,
    required double waterBill,
    required double gasBill,
    required DateTime dueDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.createBill(
        tenantId: tenantId,
        rentAmount: rentAmount,
        electricityBill: electricityBill,
        waterBill: waterBill,
        gasBill: gasBill,
        dueDate: dueDate,
      );

      if (result['success']) {
        final newBill = Bill.fromJson(result['data']['bill']);
        _bills.insert(0, newBill);
      } else {
        _errorMessage = result['message'];
        throw Exception(_errorMessage ?? 'Failed to create bill');
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> makePayment(String billId, String method, String transactionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bill = _bills.firstWhere((b) => b.id == billId);
      final result = await ApiService.createPayment(
        billId: billId,
        amount: bill.totalAmount,
        paymentMethod: method,
        transactionId: transactionId,
      );

      if (result['success']) {
        await _loadBillsFromBackend();
        await loadPayments();
      } else {
        _errorMessage = result['message'];
        throw Exception(_errorMessage ?? 'Failed to make payment');
      }
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadPayments() async {
    try {
      final result = await ApiService.getPayments();
      if (result['success']) {
        _payments.clear();
        final rawPayments = (result['data'] as List).cast<Map<String, dynamic>>();
        
        final mappedPayments = rawPayments.map((p) => {
          'id': p['_id'] ?? p['id'] ?? '',
          'billId': p['billId'] is Map ? p['billId']['_id'] : p['billId'],
          'tenantId': p['tenantId'] is Map ? p['tenantId']['_id'] : p['tenantId'],
          'landlordId': p['landlordId'] is Map ? p['landlordId']['_id'] : p['landlordId'],
          'amount': (p['amount'] as num?)?.toDouble() ?? 0.0,
          'date': DateTime.parse(p['paymentDate'] ?? p['date'] ?? DateTime.now().toIso8601String()),
          'method': p['paymentMethod'] ?? 'bank_transfer',
          'status': p['status'] ?? 'completed',
          'transactionId': p['transactionId'] ?? '',
        }).toList();

        _payments.addAll(mappedPayments);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error loading payments: $e');
      return false;
    }
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

  Future<void> loadMessages() async {
    try {
      final result = await ApiService.getMessages();
      if (result['success']) {
        _messages.clear();
        final rawMessages = (result['data'] as List).cast<Map<String, dynamic>>();

        final mappedMessages = rawMessages.map((m) => {
          'id': m['_id'] ?? m['id'] ?? '',
          'senderId': m['senderId'] is Map ? m['senderId']['_id'] : m['senderId'],
          'receiverId': m['receiverId'] is Map ? m['receiverId']['_id'] : m['receiverId'],
          'text': m['text'] ?? '',
          'date': DateTime.parse(m['createdAt'] ?? m['date'] ?? DateTime.now().toIso8601String()),
        }).toList();

        _messages.addAll(mappedMessages);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    try {
      final result = await ApiService.sendMessage(
        receiverId: receiverId,
        text: text,
      );

      if (result['success']) {
        final m = result['data'];
        final newMessage = {
          'id': m['_id'] ?? m['id'] ?? '',
          'senderId': m['senderId'],
          'receiverId': m['receiverId'],
          'text': m['text'] ?? '',
          'date': DateTime.parse(m['createdAt'] ?? DateTime.now().toIso8601String()),
        };
        _messages.add(newMessage);
        notifyListeners();
      } else {
        throw Exception(result['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> getMessagesBetween(String aId, String bId) {
    final list = _messages.where((m) {
      final s = m['senderId'] as String? ?? '';
      final r = m['receiverId'] as String? ?? '';
      return (s == aId && r == bId) || (s == bId && r == aId);
    }).toList();

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
