import 'package:flutter/material.dart';

class DebouncedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Duration debounceDuration;
  final ButtonStyle? style; // Make 'style' optional

  const DebouncedButton({
    required this.onPressed,
    required this.child,
    this.debounceDuration = const Duration(seconds: 1),
    this.style, // Optional 'style' parameter
  });

  @override
  _DebouncedButtonState createState() => _DebouncedButtonState();
}

class _DebouncedButtonState extends State<DebouncedButton> {
  bool _isButtonDisabled = false;

  void _enableButton() {
    setState(() {
      _isButtonDisabled = false;
    });
  }

  void _handlePressed() {
    if (!_isButtonDisabled) {
      setState(() {
        _isButtonDisabled = true;
      });
      widget.onPressed();
      Future.delayed(widget.debounceDuration, _enableButton);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handlePressed,
      child: widget.child,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isButtonDisabled ? Colors.grey : null,
      ),
    );
  }
}
