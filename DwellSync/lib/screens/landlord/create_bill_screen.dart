import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dwell_sync/providers/auth_provider.dart';
import 'package:dwell_sync/providers/payment_provider.dart';
import 'package:dwell_sync/utils/colors.dart';
import 'package:dwell_sync/utils/format.dart';
import 'package:dwell_sync/widgets/custom_button.dart';
import 'package:dwell_sync/widgets/custom_text_field.dart';

class CreateBillScreen extends StatefulWidget {
  const CreateBillScreen({super.key});

  @override
  State<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  String? _selectedTenantId;
  final _rentController = TextEditingController();
  final _electricityController = TextEditingController();
  final _waterController = TextEditingController();
  final _gasController = TextEditingController();
  DateTime? _dueDate;

  double get _totalAmount {
    final rent = double.tryParse(_rentController.text) ?? 0;
    final electricity = double.tryParse(_electricityController.text) ?? 0;
    final water = double.tryParse(_waterController.text) ?? 0;
    final gas = double.tryParse(_gasController.text) ?? 0;
    return rent + electricity + water + gas;
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _createBill() async {
    if (_selectedTenantId == null || _rentController.text.isEmpty || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final landlordId = authProvider.currentUser?.id ?? 'landlord_1';

    try {
      await paymentProvider.createBill(
        tenantId: _selectedTenantId!,
        landlordId: landlordId,
        rentAmount: double.parse(_rentController.text),
        electricityBill: double.tryParse(_electricityController.text) ?? 0,
        waterBill: double.tryParse(_waterController.text) ?? 0,
        gasBill: double.tryParse(_gasController.text) ?? 0,
        dueDate: _dueDate!,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill created successfully!'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e is Exception ? e.toString() : 'Failed to create bill';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create bill failed: $msg')));
      return;
    }

    _rentController.clear();
    _electricityController.clear();
    _waterController.clear();
    _gasController.clear();
    setState(() {
      _selectedTenantId = null;
      _dueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final myTenants = paymentProvider.tenants
        .where((tenant) => tenant['landlordId'] == null || tenant['landlordId'] == authProvider.currentUser?.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create New Bill'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Create Tenant Bill', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Generate a professional invoice with rent and utility charges.', style: TextStyle(fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            if (myTenants.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF6E8),
                  border: Border.all(color: const Color(0xFFF2C94D)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning, size: 32),
                    const SizedBox(height: 8),
                    const Text('No tenants available yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    const Text('Tenants will appear here once they register with your invite code.', style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                  ],
                ),
              )
            else
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tenant Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedTenantId,
                        decoration: InputDecoration(
                          labelText: 'Select Tenant',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        items: myTenants.map((tenant) {
                          return DropdownMenuItem<String>(
                            value: tenant['id'],
                            child: Text('${tenant['name']} (${tenant['email']})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTenantId = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),
            if (myTenants.isNotEmpty) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Billing Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _rentController,
                        label: 'Rent Amount (৳) *',
                        hintText: 'Enter rent amount',
                        prefixIcon: Icons.home_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _electricityController,
                        label: 'Electricity Bill (৳)',
                        hintText: 'Enter electricity bill',
                        prefixIcon: Icons.electrical_services_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _waterController,
                        label: 'Water Bill (৳)',
                        hintText: 'Enter water bill',
                        prefixIcon: Icons.water_drop_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _gasController,
                        label: 'Gas Bill (৳)',
                        hintText: 'Enter gas bill',
                        prefixIcon: Icons.gas_meter_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: _selectDueDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, color: AppColors.secondary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _dueDate == null ? 'Select due date' : AppFormat.formatDate(_dueDate!),
                                  style: TextStyle(color: _dueDate == null ? AppColors.textSecondary : AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F7F4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Invoice Total', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('Amount due', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    Text(AppFormat.formatCurrency(_totalAmount), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              CustomButton(text: 'Create Bill', onPressed: _createBill, color: AppColors.secondary),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rentController.dispose();
    _electricityController.dispose();
    _waterController.dispose();
    _gasController.dispose();
    super.dispose();
  }
}

