import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/screens/setting/GenderSelectionModal.dart';
import 'package:bnn/screens/setting/email.dart';
import 'package:bnn/screens/setting/phone.dart';
import 'package:bnn/screens/setting/username.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final supabase = Supabase.instance.client;

  final TextEditingController aboutController = TextEditingController();
  int? selectedOption;
  var age = 25;

  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  final List<String> ageList =
      List.generate(100, (index) => (index + 1).toString());

  @override
  void initState() {
    super.initState();
    initialData();
  }

  void initialData() async {
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final meProfile = authProvider.profile!;
    setState(() {
      _loading = true;
      aboutController.text = meProfile.bio ?? '';
      selectedOption = meProfile.gender;
    });
  }

  Future<void> _uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final publicUrl = await authProvider.uploadAvatar(image: image);

        final profile = {"avatar": publicUrl};
        await authProvider.setProfile(profile);
        await authProvider.updateProfile();

        CustomToast.showToastSuccessTop(
            context, 'Profile updated successfully!');
        Navigator.pushNamed(context, '/home');
      } catch (e) {
        CustomToast.showToastWarningTop(
            context, 'Error uploading image: ${e.toString()}');
      }
    }
  }

  void _showGender(BuildContext context, AuthProvider authProvider) {
    final meProfile = authProvider.profile;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GenderSelectionModal(
          initialSelectedOption: meProfile!.gender,
          onContinue: (selectedGender) async {
            final profile = {"gender": selectedGender};
            await authProvider.setProfile(profile);
            await authProvider.updateProfile();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);
    final meProfile = authProvider.profile!;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(
            'Edit Profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4D4C4A),
              fontSize: 14,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                                      image: NetworkImage(meProfile.avatar!),
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
                          image:
                              AssetImage('assets/images/settings/profile.png'),
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
                  color: Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.circular(15.0),
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
                    hintText: meProfile.bio,
                    contentPadding: EdgeInsets.all(12),
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
                  onSubmitted: (value) async {
                    if (value.isNotEmpty) {
                      final profile = {"bio": value};
                      await authProvider.setProfile(profile);
                      await authProvider.updateProfile();
                    }
                  },
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
                  color: Color(0xFFE9E9E9),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(children: [
                  Column(children: [
                    GestureDetector(
                      onTap: () => showMaterialNumberPicker(
                        context: context,
                        title: 'Select Your Age',
                        maxNumber: 100,
                        minNumber: 15,
                        selectedNumber: meProfile.age,
                        onChanged: (value) async {
                          final profile = {"age": value};
                          await authProvider.setProfile(profile);
                          await authProvider.updateProfile();
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
                        _showGender(context, authProvider);
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
