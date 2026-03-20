import 'package:flutter/material.dart';
import '../utils/app_localization.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> application;

  const PaymentPage({
    super.key,
    required this.application,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const List<String> _paymentMethodKeys = <String>[
    'bank_transfer',
    'e_wallet',
    'credit_debit_card',
    'cash_at_branch',
  ];

  String _selectedMethod = _paymentMethodKeys.first;

  @override
  Widget build(BuildContext context) {
    final title = context.t('Payment Page', 'Trang thanh toán');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t(
                  'Select a payment method',
                  'Chọn phương thức thanh toán',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 12),
              ..._paymentMethodKeys.map((method) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE3E8F4)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RadioListTile<String>(
                    value: method,
                    groupValue: _selectedMethod,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedMethod = value;
                      });
                    },
                    activeColor: const Color(0xFF4C40F7),
                    title: Text(
                      _localizedMethod(method, context),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1F3F),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C40F7),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.t(
                            'Payment method selected: ${_localizedMethod(_selectedMethod, context)}',
                            'Đã chọn phương thức thanh toán: ${_localizedMethod(_selectedMethod, context)}',
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    context.t('Continue', 'Tiếp tục'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedMethod(String key, BuildContext context) {
    switch (key) {
      case 'bank_transfer':
        return context.t('Bank Transfer', 'Chuyển khoản ngân hàng');
      case 'e_wallet':
        return context.t('E-Wallet', 'Ví điện tử');
      case 'credit_debit_card':
        return context.t('Credit / Debit Card', 'Thẻ tín dụng / ghi nợ');
      case 'cash_at_branch':
        return context.t('Cash at Branch', 'Tiền mặt tại quầy');
      default:
        return key;
    }
  }
}
