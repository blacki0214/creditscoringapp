import 'package:cloud_firestore/cloud_firestore.dart';

class Installment {
  final String id;
  final String loanOfferId;
  final int installmentNumber;
  final DateTime dueDate;
  final double amountVnd;
  final double principalVnd;
  final double interestVnd;
  final String status; // 'incoming', 'due', 'paid', 'overdue'
  final DateTime? paidAt;
  final int lateDays; // 0 if not overdue
  final DateTime createdAt;
  final DateTime? updatedAt;

  Installment({
    required this.id,
    required this.loanOfferId,
    required this.installmentNumber,
    required this.dueDate,
    required this.amountVnd,
    required this.principalVnd,
    required this.interestVnd,
    required this.status,
    this.paidAt,
    this.lateDays = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get status display (English)
  String get statusDisplay {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'due':
        return 'Due';
      case 'overdue':
        return 'Overdue';
      case 'incoming':
      default:
        return 'Incoming';
    }
  }

  /// Get status display (Vietnamese)
  String get statusDisplayVi {
    switch (status) {
      case 'paid':
        return 'Đã thanh toán';
      case 'due':
        return 'Đến hạn';
      case 'overdue':
        return 'Quá hạn';
      case 'incoming':
      default:
        return 'Sắp đến hạn';
    }
  }

  /// Check if this installment is late
  bool get isLate => status == 'overdue';

  /// Check if this installment is paid
  bool get isPaid => status == 'paid';

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'loanOfferId': loanOfferId,
      'installmentNumber': installmentNumber,
      'dueDate': Timestamp.fromDate(dueDate),
      'amountVnd': amountVnd,
      'principalVnd': principalVnd,
      'interestVnd': interestVnd,
      'status': status,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'lateDays': lateDays,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create from Firestore document
  factory Installment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Installment(
      id: doc.id,
      loanOfferId: data['loanOfferId'] as String? ?? '',
      installmentNumber: data['installmentNumber'] as int? ?? 0,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amountVnd: (data['amountVnd'] as num?)?.toDouble() ?? 0.0,
      principalVnd: (data['principalVnd'] as num?)?.toDouble() ?? 0.0,
      interestVnd: (data['interestVnd'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'incoming',
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      lateDays: data['lateDays'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Map constructor (from API/local storage)
  factory Installment.fromMap(Map<String, dynamic> map, {required String id}) {
    return Installment(
      id: id,
      loanOfferId: map['loanOfferId'] as String? ?? '',
      installmentNumber: map['installmentNumber'] as int? ?? 0,
      dueDate: map['dueDate'] is DateTime
          ? map['dueDate'] as DateTime
          : DateTime.parse(map['dueDate'].toString()),
      amountVnd: (map['amountVnd'] as num?)?.toDouble() ?? 0.0,
      principalVnd: (map['principalVnd'] as num?)?.toDouble() ?? 0.0,
      interestVnd: (map['interestVnd'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'incoming',
      paidAt: map['paidAt'] != null
          ? map['paidAt'] is DateTime
              ? map['paidAt'] as DateTime
              : DateTime.parse(map['paidAt'].toString())
          : null,
      lateDays: map['lateDays'] as int? ?? 0,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.parse(map['createdAt'].toString()),
      updatedAt: map['updatedAt'] != null
          ? map['updatedAt'] is DateTime
              ? map['updatedAt'] as DateTime
              : DateTime.parse(map['updatedAt'].toString())
          : null,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loanOfferId': loanOfferId,
      'installmentNumber': installmentNumber,
      'dueDate': dueDate.toIso8601String(),
      'amountVnd': amountVnd,
      'principalVnd': principalVnd,
      'interestVnd': interestVnd,
      'status': status,
      'paidAt': paidAt?.toIso8601String(),
      'lateDays': lateDays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Installment(#$installmentNumber, $status, $amountVnd₫, $dueDate)';
  }
}
