import 'package:flutter/material.dart';
import 'package:dwell_sync/models/bill.dart';

class PaymentProvider extends ChangeNotifier {
  final List<Bill> _bills = [];
  bool _isLoading = false;

  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;

  // Get all bills
  List<Bill> getAllBills() {
    return _bills;
  }

  // Get bills for tenant
  List<Bill> getBillsForTenant(String tenantId) {
    return _bills.where((bill) => bill.tenantId == tenantId).toList();
  }

  // Get bills for landlord
  List<Bill> getBillsForLandlord(String landlordId) {
    return _bills.where((bill) => bill.landlordId == landlordId).toList();
  }

  // Add bill
  void addBill(Bill bill) {
    _bills.add(bill);
    notifyListeners();
  }

  // Update bill
  void updateBill(String billId, Bill updatedBill) {
    final index = _bills.indexWhere((bill) => bill.id == billId);
    if (index != -1) {
      _bills[index] = updatedBill;
      notifyListeners();
    }
  }

  // Delete bill
  void deleteBill(String billId) {
    _bills.removeWhere((bill) => bill.id == billId);
    notifyListeners();
  }

  // Mark bill as paid
  void markAsPaid(String billId) {
    final index = _bills.indexWhere((bill) => bill.id == billId);
    if (index != -1) {
      _bills[index] = _bills[index].copyWith(status: 'paid');
      notifyListeners();
    }
  }

  // Mark bill as unpaid
  void markAsUnpaid(String billId) {
    final index = _bills.indexWhere((bill) => bill.id == billId);
    if (index != -1) {
      _bills[index] = _bills[index].copyWith(status: 'unpaid');
      notifyListeners();
    }
  }

  // Get total bills amount
  double getTotalAmount() {
    return _bills.fold(0, (sum, bill) => sum + bill.amount);
  }

  // Get total paid amount
  double getTotalPaidAmount() {
    return _bills
        .where((bill) => bill.status == 'paid')
        .fold(0, (sum, bill) => sum + bill.amount);
  }

  // Get total unpaid amount
  double getTotalUnpaidAmount() {
    return _bills
        .where((bill) => bill.status == 'unpaid' || bill.status == 'overdue')
        .fold(0, (sum, bill) => sum + bill.amount);
  }

  // Get pending bills count
  int getPendingBillsCount() {
    return _bills
        .where((bill) => bill.status == 'unpaid' || bill.status == 'overdue')
        .length;
  }
}
