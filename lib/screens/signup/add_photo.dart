import 'dart:io';
import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:bnn/widgets/buttons/button-gradient-primary.dart';
import 'package:bnn/widgets/buttons/button-primary.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bnn/utils/constants.dart';
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
      final publicUrl =
          "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y";

      final profile = {"avatar": publicUrl};
      await authProvider.setProfile(profile);
      await authProvider.updateProfile();

      CustomToast.showToastSuccessTop(context, 'Profile updated successfully!');
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      CustomToast.showToastWarningTop(
          context, 'Error uploading image: ${e.toString()}');
    }
  }

  void _showUploadMethod(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
            top: Radius.circular(30)), // Set the radius
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
                gradientColors: [
                  // Gradient colors
                  AppColors.primaryBlack,
                  Color(0xFF6A0200)
                ],
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
    return Scaffold(
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
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Centering horizontally
                mainAxisSize: MainAxisSize
                    .min, // To prevent Column from taking up more space than necessary
                children: [
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Image.asset(
                        Constants.addphoto, // Replace with your logo asset
                        height: 200, // Adjust height as necessary
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text("Add your photo",
                      textAlign: TextAlign.center, // Centering text
                      style: TextStyle(
                          fontFamily: "Archivo",
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  SizedBox(height: 10),
                  Text(
                    "Add your photo to be easily recognized via your profile",
                    textAlign: TextAlign.center, // Centering text
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
                gradientColors: [AppColors.primaryBlack, AppColors.primaryRed]),
            SizedBox(height: 5),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
              child: Text(
                "Skip",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            )
          ],
        )),
      ),
    );
  }
}
