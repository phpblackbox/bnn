import 'package:bnn/utils/colors.dart';
import 'package:flutter/material.dart';

class ButtonPrimary extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const ButtonPrimary({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.textColor = AppColors.primaryBlack,
    this.backgroundColor = const Color.fromARGB(255, 255, 255, 255),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: textColor),
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.only(left: 14), // Add left padding here
            child: Icon(icon, color: textColor),
          ),
          Expanded(
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Poppins',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
