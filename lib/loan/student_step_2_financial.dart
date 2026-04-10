import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/app_localization.dart';
import '../viewmodels/student_loan_viewmodel.dart';
import 'student_step_3_result.dart';

class StudentStepBFinancialPage extends StatefulWidget {
  const StudentStepBFinancialPage({super.key});

  @override
  State<StudentStepBFinancialPage> createState() =>
      _StudentStepBFinancialPageState();
}

class _StudentStepBFinancialPageState extends State<StudentStepBFinancialPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _incomeController;
  late TextEditingController _expenseController;
  final _incomeFieldKey = GlobalKey<FormFieldState<String>>();
  final _expenseFieldKey = GlobalKey<FormFieldState<String>>();
  final _incomeFocusNode = FocusNode();
  final _expenseFocusNode = FocusNode();
  final NumberFormat _amountFormatter = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    final vm = context.read<StudentLoanViewModel>();
    _incomeController = TextEditingController(
      text: _formatAmount(vm.monthlyIncome),
    );
    _expenseController = TextEditingController(
      text: _formatAmount(vm.monthlyExpenses),
    );

    _incomeFocusNode.addListener(() {
      if (!_incomeFocusNode.hasFocus) {
        _incomeFieldKey.currentState?.validate();
      }
    });
    _expenseFocusNode.addListener(() {
      if (!_expenseFocusNode.hasFocus) {
        _expenseFieldKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _expenseController.dispose();
    _incomeFocusNode.dispose();
    _expenseFocusNode.dispose();
    super.dispose();
  }

  String _formatAmount(double value) {
    return _amountFormatter.format(value.round()).replaceAll(',', '.');
  }

  void _syncTextFields(StudentLoanViewModel vm) {
    final incomeText = _formatAmount(vm.monthlyIncome);
    if (_incomeController.text != incomeText) {
      _incomeController.text = incomeText;
      _incomeController.selection = TextSelection.collapsed(
        offset: _incomeController.text.length,
      );
    }

    final expenseText = _formatAmount(vm.monthlyExpenses);
    if (_expenseController.text != expenseText) {
      _expenseController.text = expenseText;
      _expenseController.selection = TextSelection.collapsed(
        offset: _expenseController.text.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentLoanViewModel>();
    _syncTextFields(vm);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        title: Text(
          context.t('Student Path - Step 2', 'Vay dành cho sinh viên - Bước 2'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1F3F),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FinancialCard(
                  title: context.t('Part-time income', 'Thu nhập làm thêm'),
                  valueText: context.t(
                    'Range: 0 - 5.000.000 VND',
                    'Khoảng: 0 - 5.000.000 VND',
                  ),
                  inputField: TextFormField(
                    key: _incomeFieldKey,
                    controller: _incomeController,
                    focusNode: _incomeFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _DotThousandsInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      suffixText: 'VND',
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(
                        (value ?? '').replaceAll('.', ''),
                      );
                      if (parsed == null) {
                        return context.t(
                          'Please enter part-time income',
                          'Vui lòng nhập thu nhập làm thêm',
                        );
                      }
                      if (parsed < 0 || parsed > 5000000) {
                        return context.t(
                          'Income must be between 0 and 5.000.000',
                          'Thu nhập phải trong khoảng 0 đến 5.000.000',
                        );
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final parsed = double.tryParse(value.replaceAll('.', ''));
                      if (parsed == null) return;
                      vm.updateFinancial(income: parsed.clamp(0, 5000000));
                    },
                  ),
                ),
                const SizedBox(height: 10),
                _FinancialCard(
                  title: context.t(
                    'Monthly expenses (optional)',
                    'Chi tiêu hàng tháng (tùy chọn)',
                  ),
                  valueText: context.t(
                    'Range: 1.000.000 - 10.000.000 VND',
                    'Khoảng: 1.000.000 - 10.000.000 VND',
                  ),
                  inputField: TextFormField(
                    key: _expenseFieldKey,
                    controller: _expenseController,
                    focusNode: _expenseFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _DotThousandsInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      suffixText: 'VND',
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(
                        (value ?? '').replaceAll('.', ''),
                      );
                      if (parsed == null) {
                        return context.t(
                          'Please enter monthly expenses',
                          'Vui lòng nhập chi tiêu hàng tháng',
                        );
                      }
                      if (parsed < 1000000 || parsed > 10000000) {
                        return context.t(
                          'Expenses must be between 1.000.000 and 10.000.000',
                          'Chi tiêu phải trong khoảng 1.000.000 đến 10.000.000',
                        );
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final parsed = double.tryParse(value.replaceAll('.', ''));
                      if (parsed == null) return;
                      vm.updateFinancial(
                        expenses: parsed.clamp(1000000, 10000000),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE7EBFF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('Do you have savings?', 'Có tiết kiệm?'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: vm.hasBuffer,
                        onChanged: (value) => vm.updateFinancial(buffer: value),
                        title: Text(
                          vm.hasBuffer
                              ? context.t(
                                  'Emergency buffer available',
                                  'Đã có quỹ dự phòng',
                                )
                              : context.t(
                                  'No emergency buffer yet',
                                  'Chưa có quỹ dự phòng',
                                ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.t(
                          'Declare to increase approval chance',
                          'Khai báo để tăng cơ hội duyệt',
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE7EBFF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('Support sources', 'Nguồn hỗ trợ tài chính'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F3F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SupportChip(
                            label: context.t('Family', 'Gia đình'),
                            value: 'family',
                          ),
                          _SupportChip(
                            label: context.t('Work', 'Việc làm'),
                            value: 'work',
                          ),
                          _SupportChip(
                            label: context.t('Scholarship', 'Học bổng'),
                            value: 'scholarship',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (vm.suspiciousIncomeWithoutSupport) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD54F)),
                    ),
                    child: Text(
                      context.t(
                        'Warning: High income but no support source selected.',
                        'Cảnh báo: Thu nhập cao nhưng chưa khai báo nguồn hỗ trợ.',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF694D00),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      await vm.calculateLimit();
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentStepCResultPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D4AF9),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(
                      context.t('Continue to Step 3', 'Tiếp tục sang Bước 3'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final number = int.tryParse(digits);
    if (number == null) return oldValue;

    final formatted = NumberFormat(
      '#,###',
      'vi_VN',
    ).format(number).replaceAll(',', '.');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  const _FinancialCard({
    required this.title,
    required this.valueText,
    required this.inputField,
  });

  final String title;
  final String valueText;
  final Widget inputField;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EBFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F3F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            valueText,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1F3F)),
          ),
          const SizedBox(height: 8),
          inputField,
        ],
      ),
    );
  }
}

class _SupportChip extends StatelessWidget {
  const _SupportChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentLoanViewModel>();
    final isSelected = vm.supportSources.contains(value);

    return FilterChip(
      selectedColor: const Color(0xFFE8EBFF),
      side: BorderSide(
        color: isSelected ? const Color(0xFF4D4AF9) : const Color(0xFFDDE3FF),
      ),
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        final updated = {...vm.supportSources};
        if (selected) {
          updated.add(value);
        } else {
          updated.remove(value);
        }
        vm.updateFinancial(sources: updated);
      },
    );
  }
}
