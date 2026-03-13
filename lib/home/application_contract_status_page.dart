import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApplicationContractStatusPage extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApplicationContractStatusPage({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final isApproved = application['approved'] == true;
    final submittedAtRaw = application['timestamp'] ?? application['submitted_at'];
    final submittedAt = submittedAtRaw != null
        ? DateTime.tryParse(submittedAtRaw.toString())
        : null;

    final tenorMonths = _asInt(application['loanTermMonths']);
    final monthlyPayment = _asDouble(application['monthlyPaymentVnd']);
    final interestRate = _asDouble(application['interestRate']);
    final loanAmount = _asDouble(application['loanAmount']);

    final firstDueDate = (submittedAt != null && tenorMonths != null)
        ? _addMonthsSafe(submittedAt, 1)
        : null;
    final finalDueDate = (submittedAt != null && tenorMonths != null)
        ? _addMonthsSafe(submittedAt, tenorMonths)
        : null;

    final statusText = isApproved
        ? (application['contractStatus']?.toString() ?? 'Active')
        : 'Rejected';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Contract Status',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isApproved
                      ? const Color(0xFF4CAF50).withOpacity(0.08)
                      : const Color(0xFFEF5350).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isApproved
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF5350),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved ? Icons.check_circle : Icons.cancel,
                      color: isApproved
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF5350),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isApproved
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFEF5350),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                children: [
                  _buildRow(
                    'Submitted At',
                    submittedAt != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(submittedAt)
                        : 'N/A',
                  ),
                  _buildRow(
                    'Loan Amount',
                    loanAmount != null ? currencyFormat.format(loanAmount) : 'N/A',
                  ),
                  _buildRow(
                    'Tenor',
                    tenorMonths != null ? '$tenorMonths months' : 'N/A',
                  ),
                  _buildRow(
                    'Monthly Payment',
                    monthlyPayment != null
                        ? currencyFormat.format(monthlyPayment)
                        : 'N/A',
                  ),
                  _buildRow(
                    'Interest Rate',
                    interestRate != null
                        ? '${interestRate.toStringAsFixed(2)}% / year'
                        : 'N/A',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCard(
                title: 'Repayment Timeline',
                children: [
                  _buildRow(
                    'First Due Date',
                    firstDueDate != null
                        ? DateFormat('dd/MM/yyyy').format(firstDueDate)
                        : 'N/A',
                  ),
                  _buildRow(
                    'Final Due Date',
                    finalDueDate != null
                        ? DateFormat('dd/MM/yyyy').format(finalDueDate)
                        : 'N/A',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({String? title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E8F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F3F),
              ),
            ),
            const SizedBox(height: 10),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1F3F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  DateTime _addMonthsSafe(DateTime base, int monthsToAdd) {
    final targetYear = base.year + ((base.month - 1 + monthsToAdd) ~/ 12);
    final targetMonth = ((base.month - 1 + monthsToAdd) % 12) + 1;
    final daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    final safeDay = base.day > daysInTargetMonth ? daysInTargetMonth : base.day;

    return DateTime(
      targetYear,
      targetMonth,
      safeDay,
      base.hour,
      base.minute,
      base.second,
      base.millisecond,
      base.microsecond,
    );
  }
}