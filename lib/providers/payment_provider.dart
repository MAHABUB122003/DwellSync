import 'package:flutter/material.dart';
import 'auth_provider.dart';

class PaymentProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _bills = [];
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _tenants = [];

  List<Map<String, dynamic>> get bills => _bills;
  List<Map<String, dynamic>> get payments => _payments;
  List<Map<String, dynamic>> get tenants => _tenants;

  void addTenantFromUser(User user) {
    if (user.role == 'tenant') {
      _tenants.add({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'landlordId': user.landlordId,
      });
      notifyListeners();
    }
  }

  double getTotalCollectedForLandlord(String landlordId) {
    return _payments
        .where((p) => _getLandlordIdForTenant(p['tenantId']) == landlordId)
        .fold(0.0, (sum, p) => sum + (p['amount'] as double));
  }

  int getActiveTenantsCountForLandlord(String landlordId) {
    return _tenants.where((t) => t['landlordId'] == landlordId).length;
  }

  int getTotalPaidBillsCountForLandlord(String landlordId) {
    return _payments
        .where((p) => _getLandlordIdForTenant(p['tenantId']) == landlordId)
        .length;
  }

  List<Map<String, dynamic>> getPendingBillsForLandlord(String landlordId) {
    final tenantIds = _tenants
        .where((t) => t['landlordId'] == landlordId)
        .map((t) => t['id'] as String)
        .toList();
    
    return _bills
        .where((b) => tenantIds.contains(b['tenantId']) && !b['isPaid'])
        .toList();
  }

  int getTotalPaidBillsCount() {
    return _payments.length;
  }

  List<Map<String, dynamic>> getRecentPaidBillsForLandlord(String landlordId) {
    final tenantIds = _tenants
        .where((t) => t['landlordId'] == landlordId)
        .map((t) => t['id'] as String)
        .toList();
    
    return _payments
        .where((p) => tenantIds.contains(p['tenantId']))
        .map((p) => {
          ...p,
          'tenantName': _getTenantName(p['tenantId']),
        })
        .toList();
  }

  String _getTenantName(String tenantId) {
    final tenant = _tenants.firstWhere((t) => t['id'] == tenantId, orElse: () => {});
    return tenant['name'] ?? 'Unknown Tenant';
  }

  String _getLandlordIdForTenant(String tenantId) {
    final tenant = _tenants.firstWhere((t) => t['id'] == tenantId, orElse: () => {});
    return tenant['landlordId'] ?? '';
  }

  Future<void> sendReminder(String tenantId, String message) async {
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Reminder sent to $tenantId: $message');
  }
}