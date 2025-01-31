import 'package:bnn/main.dart';
import 'package:bnn/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'ButtonGradientMain.dart';
import './interests.dart';

class Age extends StatefulWidget {
  const Age({super.key});

  @override
  State<Age> createState() => _AgeState();
}

class _AgeState extends State<Age> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  var age = 25;

  final List<String> ageList =
      List.generate(100, (index) => (index + 1).toString());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0))
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Start the animation
    _controller.forward();
  }

  bool get isButtonEnabled {
    return true;
  }

  Future<void> _update() async {
    if (isButtonEnabled) {
      try {
        final userId = supabase.auth.currentUser!.id;

        await supabase.from('profiles').upsert({
          'id': userId,
          'age': age,
        });

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Interests()));
      } catch (error) {
        CustomToast.showToastWarningBottom(
            context, 'Error updating profile: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My age is",
          style: TextStyle(fontFamily: "Archivo"),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
          child: Column(
        children: [
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 150.0,
                      child: TextButton(
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Your age',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        onPressed: () => showMaterialNumberPicker(
                          context: context,
                          title: 'Select Your Age',
                          maxNumber: 100,
                          minNumber: 15,
                          selectedNumber: age,
                          onChanged: (value) => setState(() => age = value),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        age.toString(),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Spacer(),
          ButtonGradientMain(
            label: 'Continue',
            onPressed: _update,
            textColor: Colors.white,
            gradientColors: isButtonEnabled
                ? [Color(0xFF000000), Color(0xFF820200)] // Active gradient
                : [
                    Color(0xFF820200).withOpacity(0.5),
                    Color(0xFF000000).withOpacity(0.5)
                  ],
          ),
        ],
      )),
    );
  }
}
