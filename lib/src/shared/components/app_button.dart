import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final Function()? action;

  const AppButton({
    super.key,
    required this.label,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: action,
        child: Text(label),
      ),
    );
  }
}