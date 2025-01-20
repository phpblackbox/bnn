import 'package:bnn/main.dart';
import 'package:bnn/screens/signup/gender.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './CustomInputField.dart';
import 'ButtonGradientMain.dart';
import './setupPassword.dart';

class CreateUserName extends StatefulWidget {
  const CreateUserName({super.key});

  @override
  _CreateUserName createState() => _CreateUserName();
}

class _CreateUserName extends State<CreateUserName>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();

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
    return usernameController.text.isNotEmpty;
  }

  Future<void> _update() async {
    if (isButtonEnabled) {
      try {
        final userId = supabase.auth.currentUser!.id;

        await supabase.from('profiles').upsert({
          'id': userId,
          'username': usernameController.text,
        });

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Gender()));
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
      appBar: AppBar(
        title: Text(
          "Create Username",
          style: TextStyle(fontFamily: "Archivo"),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        CustomInputField(
                          placeholder: 'Create your username',
                          controller: usernameController,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            ButtonGradientMain(
              label: 'Continue',
              onPressed: _update,
              // onPressed: () {
              //   if (isButtonEnabled) {
              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (context) => SetupPassowrd()));
              //   }
              // },
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
