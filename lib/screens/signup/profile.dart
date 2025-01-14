import 'package:bnn/main.dart';
import 'package:flutter/material.dart';
import 'ButtonGradientMain.dart';
import './CustomInputField.dart';
import './age.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController biocontroller = TextEditingController();

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
    return firstnameController.text.isNotEmpty &&
        lastnameController.text.isNotEmpty;
  }

  Future<void> _update() async {
    if (isButtonEnabled) {
      try {
        final userId = supabase.auth.currentUser!.id;

        await supabase.from('profiles').upsert({
          'id': userId,
          'first_name': firstnameController.text.trim(),
          'last_name': lastnameController.text.trim(),
          'bio': biocontroller.text.trim(),
        });

        Navigator.push(context, MaterialPageRoute(builder: (context) => Age()));
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontFamily: "Archivo"),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 32, top: 16, right: 32, bottom: 32),
        child: Column(
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Full name",
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        CustomInputField(
                          placeholder: 'First name',
                          controller: firstnameController,
                          onChanged: (value) {
                            setState(
                                () {}); // Update state on email field change
                          },
                        ),
                        SizedBox(height: 10),
                        CustomInputField(
                          placeholder: 'Last name',
                          controller: lastnameController,
                          onChanged: (value) {
                            setState(
                                () {}); // Update state on email field change
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Bio",
                    ),
                    SizedBox(height: 10),
                    TextField(
                      style: TextStyle(fontSize: 12.0, fontFamily: "Poppins"),
                      maxLines: 5,
                      controller: biocontroller,
                      decoration: InputDecoration(
                        hintText: "Create a short bio",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              20.0), // Set the border radius
                          borderSide: BorderSide(
                              color: Colors
                                  .transparent), // Make the border transparent
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(20.0), // Consistent radius
                          borderSide: BorderSide(
                              color: Colors
                                  .transparent), // Make the enabled border transparent
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(20.0), // Consistent radius
                          borderSide: BorderSide(
                              color: Colors
                                  .transparent), // Make the focused border transparent
                        ),
                        filled: true, // Enable the filled property
                        fillColor: Color(
                            0xFFEAEAEA), // Set the desired background color
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                    ),
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
