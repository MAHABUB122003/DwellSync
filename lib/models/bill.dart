class Bill {
  final String id;
  final String tenantId;
  final String? landlordId;
  final double amount;
  final DateTime month;
  final String status; // 'paid', 'unpaid', 'overdue'
  final DateTime dueDate;
  final DateTime createdAt;
  final String? notes;

  Bill({
    required this.id,
    required this.tenantId,
    this.landlordId,
    required this.amount,
    required this.month,
    required this.status,
    required this.dueDate,
    DateTime? createdAt,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Bill to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'landlordId': landlordId,
      'amount': amount,
      'month': month.toIso8601String(),
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  // Create Bill from JSON
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      landlordId: json['landlordId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      month: DateTime.parse(json['month'] as String),
      status: json['status'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  // Copy with method for updates
  Bill copyWith({
    String? id,
    String? tenantId,
    String? landlordId,
    double? amount,
    DateTime? month,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    String? notes,
  }) {
    return Bill(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      landlordId: landlordId ?? this.landlordId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }
}
