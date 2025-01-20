import 'package:bnn/main.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'ButtonGradientMain.dart';
import './profile.dart';

class Gender extends StatefulWidget {
  _Gender createState() => _Gender();
}

class _Gender extends State<Gender> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController usernameController = TextEditingController();

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
    return selectedGender.isNotEmpty;
  }

  // This variable keeps track of the currently selected gender
  String selectedGender = '';

  // Method to select gender and update the UI
  void selectGender(String gender) {
    setState(() {
      selectedGender = gender; // Update the selected gender
    });
  }

  Future<void> _update() async {
    if (isButtonEnabled) {
      try {
        final userId = supabase.auth.currentUser!.id;

        int gender = 0;
        switch (selectedGender) {
          case "no_gender":
            gender = 0;
            break;
          case "man":
            gender = 1;
            break;
          case "woman":
            gender = 2;
            break;
        }

        await supabase.from('profiles').upsert({
          'id': userId,
          'gender': gender,
        });

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Profile()));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $error')),
        );
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Start a timer to navigate to the next page after 3 seconds

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 200,
              child: Center(
                child: Image.asset(
                  Constants.splashLogo, // Replace with your logo asset
                  height: 200, // Adjust height as necessary
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'I am a ',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontFamily: "Archivo",
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => selectGender('man'), // Select Man
                          child: Image.asset(
                            selectedGender == 'man'
                                ? 'assets/images/gender_man_select.png'
                                : 'assets/images/gender_man.png',
                            width: 150,
                            height: 150,
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => selectGender('woman'), // Select Woman
                          child: Image.asset(
                            selectedGender == 'woman'
                                ? 'assets/images/gender_woman_select.png'
                                : 'assets/images/gender_woman.png',
                            width: 150,
                            height: 150,
                          ),
                        ),
                      ],
                    ),
                    // GestureDetector(
                    //   onTap: () =>
                    //       selectGender('no_gender'), // Select No Gender
                    //   child: Image.asset(
                    //     selectedGender == 'no_gender'
                    //         ? 'assets/images/gender_no_select.png'
                    //         : 'assets/images/gender_no.png',
                    //     width: 150,
                    //     height: 150,
                    //   ),
                    // ),
                  ],
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
        ),
      ),
    );
  }
}
