import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../utils/app_localization.dart';
import '../viewmodels/student_loan_viewmodel.dart';
import 'student_step_2_financial.dart';

class StudentStepAProfilePage extends StatefulWidget {
  const StudentStepAProfilePage({super.key});

  @override
  State<StudentStepAProfilePage> createState() =>
      _StudentStepAProfilePageState();
}

class _StudentStepAProfilePageState extends State<StudentStepAProfilePage> {
  late TextEditingController _loanAmountController;
  late TextEditingController _gpaController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<StudentLoanViewModel>();
    _loanAmountController = TextEditingController(
      text: vm.loanAmount.toString(),
    );
    _gpaController = TextEditingController(
      text: vm.gpaLatest.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _gpaController.dispose();
    super.dispose();
  }

  void _syncTextFields(StudentLoanViewModel vm) {
    final loanAmountText = vm.loanAmount.toString();
    if (_loanAmountController.text != loanAmountText) {
      _loanAmountController.text = loanAmountText;
      _loanAmountController.selection = TextSelection.collapsed(
        offset: _loanAmountController.text.length,
      );
    }

    final gpaText = vm.gpaLatest.toStringAsFixed(2);
    if (_gpaController.text != gpaText) {
      _gpaController.text = gpaText;
      _gpaController.selection = TextSelection.collapsed(
        offset: _gpaController.text.length,
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
          context.t('Student Path - Step 1', 'Vay dành cho sinh viên - Bước 1'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1F3F),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD54F)),
                ),
                child: Text(
                  context.t(
                    'Please note that this feature is still under development. If you encounter any unexpected errors, please contact the support section in the settings. Thank you.',
                    'Vui lòng lưu ý rằng tính năng này vẫn đang trong quá trình phát triển. Nếu bạn gặp phải bất kỳ lỗi nào không mong muốn, vui lòng liên hệ với bộ phận hỗ trợ trong phần cài đặt. Xin cảm ơn.',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF694D00),
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: context.t('Loan amount', 'Số tiền vay'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _loanAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        suffixText: 'đ',
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed == null) return;
                        final clamped = parsed.clamp(5000000, 10000000);
                        final rounded = ((clamped / 500000).round() * 500000);
                        vm.updateProfile(selectedLoanAmount: rounded);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.t(
                        'Allowed: 5,000,000-10,000,000 ',
                        'Cho phép: 5,000,000-10,000,000',
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
              _SectionCard(
                title: context.t('Academic year', 'Năm học'),
                child: DropdownButtonFormField<int>(
                  initialValue: vm.academicYear,
                  dropdownColor: Colors.white,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(
                    5,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(
                        context.t('Year ${index + 1}', 'Năm ${index + 1}'),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) vm.updateProfile(year: value);
                  },
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: context.t('Major', 'Ngành học'),
                child: _MajorPicker(
                  value: vm.major,
                  onChanged: (major) => vm.updateProfile(selectedMajor: major),
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: context.t('Current GPA', 'GPA hiện tại'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _gpaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed == null) return;
                        final clamped = parsed.clamp(0.0, 4.0);
                        vm.updateProfile(gpa: clamped);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: context.t('Program level', 'Bậc học'),
                child: Row(
                  children: [
                    Expanded(
                      child: _ProgramLevelChip(
                        label: context.t('University', 'Đại học'),
                        selected: vm.programLevel == 'undergraduate',
                        onTap: () => vm.updateProfile(
                          selectedProgramLevel: 'undergraduate',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ProgramLevelChip(
                        label: context.t('Graduate', 'Sau đại học'),
                        selected: vm.programLevel == 'graduate',
                        onTap: () => vm.updateProfile(
                          selectedProgramLevel: 'graduate',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: context.t('Living status', 'Tình trạng ở'),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _LivingChip(
                      label: context.t('Dormitory', 'KTX'),
                      value: 'dormitory',
                      selected: vm.livingStatus,
                      onTap: (v) => vm.updateProfile(selectedLivingStatus: v),
                    ),
                    _LivingChip(
                      label: context.t('Rent', 'Thuê'),
                      value: 'rent',
                      selected: vm.livingStatus,
                      onTap: (v) => vm.updateProfile(selectedLivingStatus: v),
                    ),
                    _LivingChip(
                      label: context.t('With parents', 'Nhà bố mẹ'),
                      value: 'with_parents',
                      selected: vm.livingStatus,
                      onTap: (v) => vm.updateProfile(selectedLivingStatus: v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudentStepBFinancialPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D4AF9),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(
                    context.t('Continue to Step 2', 'Tiếp tục sang Bước 2'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramLevelChip extends StatelessWidget {
  const _ProgramLevelChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8EBFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF4D4AF9)
                : const Color(0xFFDDE3FF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected
                ? const Color(0xFF2D2AA8)
                : const Color(0xFF1A1F3F),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  const _WarningBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFB26A00)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: Color(0xFF694D00)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LivingChip extends StatelessWidget {
  const _LivingChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8EBFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4D4AF9)
                : const Color(0xFFDDE3FF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF2D2AA8)
                : const Color(0xFF1A1F3F),
          ),
        ),
      ),
    );
  }
}

class _MajorPicker extends StatelessWidget {
  const _MajorPicker({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _MajorBottomSheet(current: value),
        );
        if (selected != null) onChanged(selected);
      },
      child: InputDecorator(
        decoration: const InputDecoration(border: OutlineInputBorder()),
        child: Row(
          children: [
            Expanded(child: Text(value)),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}

class _MajorBottomSheet extends StatefulWidget {
  const _MajorBottomSheet({required this.current});

  final String current;

  @override
  State<_MajorBottomSheet> createState() => _MajorBottomSheetState();
}

class _MajorBottomSheetState extends State<_MajorBottomSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final majors = StudentLoanViewModel.majors
        .where((m) => m.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search)),
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: ListView.separated(
                itemCount: majors.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final major = majors[index];
                  return ListTile(
                    title: Text(major),
                    trailing: major == widget.current
                        ? const Icon(Icons.check, color: Color(0xFF4D4AF9))
                        : null,
                    onTap: () => Navigator.pop(context, major),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
