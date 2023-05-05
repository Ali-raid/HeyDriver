import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  final double? buttonSize;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.color,
    this.buttonSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize:
            Size(buttonSize == null ? double.infinity : buttonSize!, 50),
        backgroundColor: color,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
