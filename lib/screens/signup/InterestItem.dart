import 'package:flutter/material.dart';

class InterestItem extends StatefulWidget {
  final String interest;
  final ValueChanged<bool> onSelected;

  const InterestItem(
      {super.key, required this.interest, required this.onSelected});

  @override
  _InterestItemState createState() => _InterestItemState();
}

class _InterestItemState extends State<InterestItem> {
  bool isSelected = false;

  void changeGradient() {
    setState(() {
      isSelected = !isSelected;
      widget.onSelected(isSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: changeGradient,
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [Color(0xFF000000), Color(0xFF5A0000)])
              : null,
          color: isSelected
              ? null // No solid color when selected
              : Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16,
              top: 4,
              right: 16,
              bottom: 4), // Adjust padding values here
          child: Text(
            widget.interest,
            style: TextStyle(
              fontSize: 13,
              fontFamily: "Nunito",
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Color(0xFF898989),
            ),
          ),
        ),
      ),
    );
  }
}
