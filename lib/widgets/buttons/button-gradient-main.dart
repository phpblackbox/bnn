import 'package:bnn/utils/colors.dart';
import 'package:flutter/material.dart';

class ButtonGradientMain extends StatelessWidget {
  final String label;
  final List<Color> gradientColors;
  final Color textColor;
  final VoidCallback onPressed;

  const ButtonGradientMain({
    super.key,
    required this.label,
    required this.onPressed,
    required this.gradientColors,
    this.textColor = AppColors.primaryBlack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Material(
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        decoration: TextDecoration.none,
                      ),
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
