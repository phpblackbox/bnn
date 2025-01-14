import 'package:bnn/main.dart';
import 'package:bnn/models/profiles.dart';
import 'package:bnn/screens/setting/email.dart';
import 'package:bnn/screens/setting/phone.dart';
import 'package:bnn/screens/setting/username.dart';
import 'package:bnn/screens/signup/ButtonGradientMain.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';

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
    });

    // aboutController.text = 'AAAAAAAAAAAAAAAA';
    print(loadedProfile!.bio);
    aboutController.text = loadedProfile!.bio ?? '';
  }

  void _bioSubmitted(String value) async {
    if (value.isNotEmpty) {
      await supabase.from('profiles').update({
        'bio': value,
      }).eq('id', loadedProfile!.id);

      loadedProfile!.bio = value;
      await Constants.saveProfile(loadedProfile!);
    }

    // aboutController.clear();
  }

  void _showGender(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full-height modal
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          height: 220.0, // Set the height of the modal
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
                  onPressed: () {},
                  gradientColors: [Color(0xFF000000), Color(0xFF820200)])
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 4),
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
              Image(image: AssetImage("assets/images/settings/edit.png")),
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
                  borderRadius: BorderRadius.circular(15.0), // Border radius
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
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Email()));
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
                padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
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
                    hintText: 'Tell us something about yourself',
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
                padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
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
                  borderRadius: BorderRadius.circular(15.0), // Border radius
                ),
                child: Column(children: [
                  Column(children: [
                    GestureDetector(
                      onTap: () => showMaterialNumberPicker(
                        context: context,
                        title: 'Select Your Age',
                        maxNumber: 100,
                        minNumber: 15,
                        selectedNumber: age,
                        onChanged: (value) => setState(() => age = value),
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
