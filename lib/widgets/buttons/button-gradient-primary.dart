import 'package:bnn/utils/colors.dart';
import 'package:flutter/material.dart';

class ButtonGradientPrimary extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final Color textColor;
  final VoidCallback onPressed;

  const ButtonGradientPrimary({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.gradientColors,
    this.textColor = AppColors.primaryBlack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors, // Set the gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                BorderRadius.circular(30), // Match button's border radius
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 16.0,
                  child: Icon(
                    icon,
                    color: textColor,
                    size: 18,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
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
