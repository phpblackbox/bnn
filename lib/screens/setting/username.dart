import 'package:bnn/main.dart';
import 'package:bnn/models/profiles.dart';
import 'package:bnn/screens/signup/CustomInputField.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';

class Username extends StatefulWidget {
  const Username({super.key});

  @override
  _Username createState() => _Username();
}

class _Username extends State<Username> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController usernameController = TextEditingController();

  Profiles? loadedProfile;

  @override
  void initState() {
    super.initState();

    fetchdata();

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

  void fetchdata() async {
    final res = await Constants.loadProfile();

    setState(() {
      loadedProfile = res;
    });
  }

  Future<void> fetchUser() async {
    if (supabase.auth.currentUser != null) {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('User is not logged in!');
        return;
      }

      try {
        final data =
            await supabase.from('profiles').select().eq("id", userId).single();

        if (data.isNotEmpty) {
          Constants().profile = Profiles(
            id: data['id'],
            firstName: data['first_name'],
            lastName: data['last_name'],
            username: data['username'],
            age: data['age'],
            bio: data['bio'],
            gender: data['gender'],
            avatar: data['avatar'],
          );

          Profiles profile = Profiles(
            id: data['id'],
            firstName: data['first_name'],
            lastName: data['last_name'],
            username: data['username'],
            age: data['age'],
            bio: data['bio'],
            gender: data['gender'],
            avatar: data['avatar'],
          );

          await Constants.saveProfile(profile);

          final res = await Constants.loadProfile();
          if (loadedProfile != null) {
            print(
                'Loaded Profile: ${loadedProfile!.firstName} ${loadedProfile!.lastName}');
          } else {
            print('No profile found.');
            return;
          }

          setState(() {
            loadedProfile = res;
          });
        }
      } catch (e) {
        print('Caught error: $e');
        if (e.toString().contains("JWT expired")) {
          await supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    }
  }

  bool get isButtonEnabled {
    return usernameController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
        child: loadedProfile == null
            ? null
            : Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            size: 20.0, color: Color(0xFF4D4C4A)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Username',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF4D4C4A),
                          fontSize: 14,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
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
                                placeholder: loadedProfile!.username,
                                controller: usernameController,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                onSubmitted: (value) async {
                                  if (value.isNotEmpty) {
                                    await supabase.from('profiles').update({
                                      'username': value,
                                    }).eq('id', loadedProfile!.id);

                                    fetchUser();
                                  }
                                },
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Username changes will be saved  in your profile after moderation',
                                style: TextStyle(
                                  color: Color(0xFF4D4C4A),
                                  fontSize: 10,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
      ),
    );
  }
}
