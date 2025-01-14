import 'dart:io';

import 'package:bnn/main.dart';
import 'package:bnn/screens/signup/ButtonGradientPrimary.dart';
import 'package:bnn/screens/signup/ButtonPrimary.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ButtonGradientMain.dart';
import 'package:bnn/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class Photo extends StatefulWidget {
  const Photo({super.key});

  @override
  State<Photo> createState() => _PhotoState();
}

class _PhotoState extends State<Photo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _accepted = false;

  final ImagePicker _picker = ImagePicker();

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
        String randomNumStr = Constants().generateRandomNumberString(6);
        final filename = '${supabase.auth.currentUser!.id}_${randomNumStr}.png';
        // final filename = '${supabase.auth.currentUser!.id}_${randomNumStr}.png';
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
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Profile updated successfully! File: $path')),
        // );
        Navigator.pushNamed(context, '/home');
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: ${e.toString()}')),
        );
      }
      // print(response.error);
      // if (response == null) {
      //   // Get public URL of the uploaded image
      //   final publicUrlResponse = await supabase.storage
      //       .from('avatars')
      //       .getPublicUrl(filename);

      //   setState(() {
      //     _imageUrl = publicUrlResponse.data;
      //   });

      //   print('Image uploaded successfully: $_imageUrl');
      // } else {
      //   print('Error uploading image: ${response.error!.message}');
      // }
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
                  Color(0xFF000000),
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
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Centering horizontally
                    mainAxisSize: MainAxisSize
                        .min, // To prevent Column from taking up more space than necessary
                    children: [
                      Container(
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
              ),
            ),
            Spacer(),
            ButtonGradientMain(
                label: 'Add photos',
                onPressed: () {
                  _showUploadMethod(context);
                },
                textColor: Colors.white,
                gradientColors: [Color(0xFF000000), Color(0xFF820200)]),
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
