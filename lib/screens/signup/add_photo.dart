import 'dart:io';
import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/buttons/button-gradient-primary.dart';
import 'package:bnn/widgets/buttons/button-primary.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Photo extends StatefulWidget {
  const Photo({super.key});

  @override
  State<Photo> createState() => _PhotoState();
}

class _PhotoState extends State<Photo> with SingleTickerProviderStateMixin {
  final bool _accepted = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  bool get isButtonEnabled {
    return _accepted;
  }

  Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isDenied ||
          await Permission.photos.isPermanentlyDenied) {
        await Permission.photos.request();
      }
    }
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

  Future<void> handleSkip() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Log the current state
      print('Before skip - Auth state: isLoggedIn=${authProvider.isLoggedIn}, userId=${authProvider.user?.id}');
    
      final publicUrl =
          "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y";

      final profile = {"avatar": publicUrl};
      await authProvider.setProfile(profile);

      // CRITICAL: Save to database - use a try-catch to identify specific errors
      try {
        await authProvider.updateProfile();
        print('Profile updated successfully');
      } catch (updateError) {
        print('Error updating profile: $updateError');
        throw updateError;  // Re-throw to handle in outer catch
      }

      // Verify logged in state is preserved
      print('After skip - Auth state: isLoggedIn=${authProvider.isLoggedIn}, userId=${authProvider.user?.id}');

      if (!authProvider.isLoggedIn || authProvider.user == null) {
        print('Authentication lost during profile setup - attempting to recover');
        // Don't throw - instead try to gracefully handle the situation
      }

      // Show success message
      if (mounted) {
        CustomToast.showToastSuccessTop(context, 'Profile setup complete!');
      }

      // Clear navigation stack and go to home - this is critical
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
      // Navigator.pushNamed(context, '/home');
    } catch (e) {
      print('Error in handleSkip: $e');
      if (mounted) {
        CustomToast.showToastWarningTop(
          context, 'Error uploading image: ${e.toString()}');
      }
    }
  }

  void _showUploadMethod(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30), top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          height: 280.0,
          child: Column(
            children: [
              Text(
                'Choose an Upload Method',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20),
              ButtonGradientPrimary(
                icon: Icons.photo_camera,
                label: 'Camera',
                textColor: Colors.white,
                gradientColors: [AppColors.primaryBlack, Color(0xFF6A0200)],
                onPressed: () {},
              ),
              ButtonPrimary(
                icon: Icons.photo_outlined,
                label: 'Gallery',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                onPressed: _uploadImage,
              ),
              ButtonPrimary(
                icon: Icons.facebook,
                label: 'Facebook',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Photo",
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Image.asset(
                          'assets/images/addphoto.png',
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text("Add your photo",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Archivo",
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    SizedBox(height: 10),
                    Text(
                      "Add your photo to be easily recognized via your profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Spacer(),
              ButtonGradientMain(
                  label: 'Add photos',
                  onPressed: () {
                    _showUploadMethod(context);
                  },
                  textColor: Colors.white,
                  gradientColors: [
                    AppColors.primaryBlack,
                    AppColors.primaryRed
                  ]),
              SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  handleSkip();
                },
                child: Text(
                  "Skip",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            ],
          )),
        ),
      ),
    );
  }
}
