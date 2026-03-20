import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_localization.dart';
import 'payment_page.dart';

class ApplicationContractStatusPage extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApplicationContractStatusPage({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final isVietnamese = context.isVietnamese;
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
      ? context.t('Active', 'Đang hiệu lực')
      : context.t('Rejected', 'Từ chối');

    final dateTimePattern = isVietnamese ? 'dd/MM/yyyy HH:mm' : 'dd/MM/yyyy HH:mm';
    final datePattern = isVietnamese ? 'dd/MM/yyyy' : 'dd/MM/yyyy';
    final monthYearPattern = isVietnamese ? 'MM/yyyy' : 'MMM yyyy';
    final naText = context.t('N/A', 'Không có');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.t('Contract Status', 'Trạng thái hợp đồng'),
          style: const TextStyle(color: Colors.black, fontSize: 16),
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
                    context.t('Submitted At', 'Ngày nộp'),
                    submittedAt != null
                        ? DateFormat(dateTimePattern).format(submittedAt)
                        : naText,
                  ),
                  _buildRow(
                    context.t('Loan Amount', 'Số tiền vay'),
                    loanAmount != null ? currencyFormat.format(loanAmount) : naText,
                  ),
                  _buildRow(
                    context.t('Tenor', 'Kỳ hạn'),
                    tenorMonths != null
                        ? context.t('$tenorMonths months', '$tenorMonths tháng')
                        : naText,
                  ),
                  _buildRow(
                    context.t('Monthly Payment', 'Thanh toán hàng tháng'),
                    monthlyPayment != null
                        ? currencyFormat.format(monthlyPayment)
                        : naText,
                  ),
                  _buildRow(
                    context.t('Interest Rate', 'Lãi suất'),
                    interestRate != null
                        ? context.t(
                            '${interestRate.toStringAsFixed(2)}% / year',
                            '${interestRate.toStringAsFixed(2)}% / năm',
                          )
                        : naText,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCard(
                title: context.t('Repayment Timeline', 'Lịch trả nợ'),
                children: [
                  _buildRow(
                    context.t('First Due Date', 'Kỳ trả đầu tiên'),
                    firstDueDate != null
                        ? DateFormat(datePattern).format(firstDueDate)
                        : naText,
                  ),
                  _buildRow(
                    context.t('Final Due Date', 'Kỳ trả cuối cùng'),
                    finalDueDate != null
                        ? DateFormat(datePattern).format(finalDueDate)
                        : naText,
                  ),
                ],
              ),
              if (isApproved && tenorMonths != null && monthlyPayment != null) ...[
                const SizedBox(height: 12),
                _buildCard(
                  title: context.t('Installment Schedule', 'Lịch trả góp'),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.t(
                                  'Total Installments: $tenorMonths',
                                  'Tổng số kỳ: $tenorMonths',
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1F3F),
                                ),
                              ),
                              Text(
                                currencyFormat.format(monthlyPayment),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.t(
                              'Monthly payment of ${currencyFormat.format(monthlyPayment)} starts from ${firstDueDate != null ? DateFormat('MMM yyyy').format(firstDueDate) : ""}',
                              'Khoản trả hàng tháng ${currencyFormat.format(monthlyPayment)} bắt đầu từ ${firstDueDate != null ? DateFormat(monthYearPattern).format(firstDueDate) : ""}',
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCard(
                  title: context.t('Payment Method', 'Phương thức thanh toán'),
                  children: [
                    Text(
                      context.t(
                        'Choose a payment method to pay your monthly installment.',
                        'Chọn phương thức thanh toán để trả góp hàng tháng.',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667085),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C40F7),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentPage(
                                application: application,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          context.t('Pay now', 'Thanh toán ngay'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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