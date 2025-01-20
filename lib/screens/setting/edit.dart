import 'dart:io';

import 'package:bnn/main.dart';
import 'package:bnn/models/profiles.dart';
import 'package:bnn/screens/setting/GenderSelectionModal.dart';
import 'package:bnn/screens/setting/email.dart';
import 'package:bnn/screens/setting/phone.dart';
import 'package:bnn/screens/setting/username.dart';
import 'package:bnn/screens/signup/ButtonGradientMain.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:flutter_supabase_chat_core/flutter_supabase_chat_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController aboutController = TextEditingController();
  int? selectedOption;
  var age = 25;
  Profiles? loadedProfile;
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  final List<String> ageList =
      List.generate(100, (index) => (index + 1).toString());

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  void fetchdata() async {
    final res = await Constants.loadProfile();

    setState(() {
      loadedProfile = res;
      _loading = true;
      aboutController.text = loadedProfile!.bio ?? '';
      selectedOption = loadedProfile!.gender;
    });
  }

  void _bioSubmitted(String value) async {
    if (value.isNotEmpty) {
      await supabase.from('profiles').update({
        'bio': value,
      }).eq('id', loadedProfile!.id);

      fetchUser();
    }

    // aboutController.clear();
  }

  Future<void> _uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _loading = false;
    });

    if (image != null) {
      try {
        String randomNumStr = Constants().generateRandomNumberString(6);
        final filename = '${supabase.auth.currentUser!.id}_$randomNumStr.png';
        final fileBytes = await File(image.path).readAsBytes();

        await supabase.storage.from('avatars').uploadBinary(
              filename,
              fileBytes,
            );

        final publicUrl =
            supabase.storage.from('avatars').getPublicUrl(filename);
        print('Image uploaded successfully! URL: $publicUrl');

        final userId = supabase.auth.currentUser!.id;

        await supabase.from('profiles').upsert({
          'id': userId,
          'avatar': publicUrl,
        });

        fetchUser();
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: ${e.toString()}')),
        );
      }
    }

    setState(() {
      _loading = true;
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

          await SupabaseChatCore.instance.updateUser(
            types.User(
                firstName: data['first_name'],
                id: data['id'],
                lastName: data['last_name'],
                imageUrl: data['avatar']),
          );

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

  void _showGender(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full-height modal
      builder: (BuildContext context) {
        return GenderSelectionModal(
          initialSelectedOption:
              loadedProfile!.gender, // Pass current selection if needed
          onContinue: (selectedGender) async {
            // Handle the continue action here
            await supabase.from('profiles').upsert({
              'id': loadedProfile!.id,
              'gender': selectedGender,
            });

            fetchUser(); // Call your fetch user function here
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: loadedProfile == null
            ? null
            : Container(
                padding:
                    const EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Edit Profile',
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
                    // Image(image: NetworkImage(loadedProfile!.avatar)),
                    SizedBox(
                      width: double.infinity,
                      height: 270,
                      child: Stack(
                        children: [
                          _loading
                              ? Container(
                                  decoration: BoxDecoration(
                                    image: _loading
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                loadedProfile!.avatar),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: GestureDetector(
                              onTap: _uploadImage,
                              child: Image(
                                image: AssetImage(
                                    'assets/images/settings/profile.png'),
                                width: 32,
                                height: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      child: Text(
                        'Profile Information',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 16, top: 12, right: 16, bottom: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFFE9E9E9), // Grey background color
                        borderRadius:
                            BorderRadius.circular(15.0), // Border radius
                      ),
                      child: Column(children: [
                        Column(children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Username()));
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Username',
                                  style: TextStyle(
                                    color: Color(0xFF4D4C4A),
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w700,
                                    height: 1.06,
                                    letterSpacing: -0.11,
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios,
                                    size: 12, color: Color(0xFF8A8B8F)),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Divider(),
                          SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Email()));
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    color: Color(0xFF4D4C4A),
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w700,
                                    height: 1.06,
                                    letterSpacing: -0.11,
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios,
                                    size: 12, color: Color(0xFF8A8B8F)),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Divider(),
                          SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PhoneNumber()));
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Phone Number',
                                  style: TextStyle(
                                    color: Color(0xFF4D4C4A),
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w700,
                                    height: 1.06,
                                    letterSpacing: -0.11,
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios,
                                    size: 12, color: Color(0xFF8A8B8F)),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                        ]),
                      ]),
                    ),
                    Container(
                      padding:
                          EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
                      child: Text(
                        'About',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        style: TextStyle(fontSize: 12.0, fontFamily: "Poppins"),
                        controller: aboutController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: loadedProfile!.bio,
                          contentPadding: EdgeInsets.all(12),
                          // border: InputBorder.none,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          filled: true,
                          fillColor: Color(0xFFEAEAEA),
                        ),
                        onSubmitted: _bioSubmitted,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
                      child: Text(
                        'Additional Information',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 16, top: 12, right: 16, bottom: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFFE9E9E9), // Grey background color
                        borderRadius:
                            BorderRadius.circular(15.0), // Border radius
                      ),
                      child: Column(children: [
                        Column(children: [
                          GestureDetector(
                            onTap: () => showMaterialNumberPicker(
                              context: context,
                              title: 'Select Your Age',
                              maxNumber: 100,
                              minNumber: 15,
                              selectedNumber: loadedProfile!.age,
                              onChanged: (value) async {
                                await supabase.from('profiles').upsert({
                                  'id': loadedProfile!.id,
                                  'age': value,
                                });

                                fetchUser();
                              },
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Age',
                                  style: TextStyle(
                                    color: Color(0xFF4D4C4A),
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w700,
                                    height: 1.06,
                                    letterSpacing: -0.11,
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios,
                                    size: 12, color: Color(0xFF8A8B8F)),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Divider(),
                          SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              _showGender(context);
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Gender',
                                  style: TextStyle(
                                    color: Color(0xFF4D4C4A),
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w700,
                                    height: 1.06,
                                    letterSpacing: -0.11,
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios,
                                    size: 12, color: Color(0xFF8A8B8F)),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                        ]),
                      ]),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
      ),
    );
  }
}
