// lib/core_system.dart
import 'package:flutter/material.dart';
import 'config.dart';

class AppTypography {
  static const TextStyle headerStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppConfig.textPlatinum,
      letterSpacing: 1.1);
  static const TextStyle subheaderStyle =
      TextStyle(fontSize: 12, color: Colors.white38);
  static const TextStyle boldTicker = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'monospace',
      color: AppConfig.textPlatinum);
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const PrimaryButton({required this.label, required this.onPressed, Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) => ElevatedButton(
      onPressed: onPressed,
      style:
          ElevatedButton.styleFrom(backgroundColor: AppConfig.accentsChampagne),
      child: Text(label,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold)));
}

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  const CustomTextField(
      {required this.hint, required this.controller, Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) => TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: AppConfig.surfaceCardGlass,
          border: InputBorder.none));
}
