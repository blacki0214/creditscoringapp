import 'package:flutter/material.dart';

class OTPInput extends StatefulWidget {
  final void Function(String code) onCompleted;

  const OTPInput({super.key, required this.onCompleted});

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  final List<FocusNode> _nodes =
      List.generate(4, (_) => FocusNode(), growable: false);
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController(), growable: false);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 60,
          child: TextField(
            controller: _controllers[index],
            focusNode: _nodes[index],
            maxLength: 1,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              counterText: "",
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                _nodes[index + 1].requestFocus();
              }
              if (index == 3) {
                final code =
                    _controllers.map((c) => c.text).join();
                widget.onCompleted(code);
              }
            },
          ),
        );
      }),
    );
  }
}
