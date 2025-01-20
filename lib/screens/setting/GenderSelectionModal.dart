import 'package:bnn/screens/signup/ButtonGradientMain.dart';
import 'package:flutter/material.dart';

class GenderSelectionModal extends StatefulWidget {
  final int? initialSelectedOption;
  final Function(int?) onContinue;

  const GenderSelectionModal({
    super.key,
    this.initialSelectedOption,
    required this.onContinue,
  });

  @override
  _GenderSelectionModalState createState() => _GenderSelectionModalState();
}

class _GenderSelectionModalState extends State<GenderSelectionModal> {
  int? selectedOption;

  @override
  void initState() {
    super.initState();
    // Initialize selected option with the initial value passed
    selectedOption = widget.initialSelectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      height: 230.0, // Adjust height as needed
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'Gender',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4D4C4A),
              fontSize: 20,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              height: 0.85,
              letterSpacing: -0.11,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RadioListTile<int>(
                title: Text('Man'),
                value: 1,
                groupValue: selectedOption,
                activeColor: Color(0xFF800000),
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
              ),
              RadioListTile<int>(
                title: Text('Woman'),
                value: 2,
                groupValue: selectedOption,
                activeColor: Color(0xFF800000),
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
              ),
            ],
          ),
          Spacer(),
          ButtonGradientMain(
              label: "Continue",
              textColor: Colors.white,
              onPressed: () {
                widget.onContinue(selectedOption);
                Navigator.pop(context);
              },
              gradientColors: [Color(0xFF000000), Color(0xFF820200)]),
        ],
      ),
    );
  }
}
