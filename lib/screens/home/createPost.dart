import 'dart:io';

import 'package:bnn/main.dart';
import 'package:bnn/models/profiles.dart';
import 'package:bnn/screens/home/home.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  String userAvatar = "";
  final List<String> images = [
    'assets/images/post/camera.png',
  ];

  final TextEditingController _postController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile>? _selectedImages = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  Future<void> fetchdata() async {
    Profiles? loadedProfile = await Constants.loadProfile();

    if (loadedProfile != null) {
      setState(() {
        userAvatar = loadedProfile.avatar;
      });
    } else {
      print('No profile found.');
      return;
    }

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
          setState(() {
            userAvatar = data["avatar"];
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

  Future<void> pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles!.isNotEmpty) {
        setState(() {
          _selectedImages!.addAll(pickedFiles);
        });
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<void> cameraImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      print(image);

      if (image != null) {
        setState(() {
          _selectedImages!.add(image);
        });
      }
    } catch (e) {
      print('Error camera images: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No camera found. Please check your device settings.'),
      ));
    }
  }

  Future<void> post() async {
    if (_postController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please describe what’s happening')),
      );

      return;
    }

    if (_selectedImages == null) return;

    List imgUrls = [];
    try {
      setState(() {
        isLoading = true;
      });
      for (var image in _selectedImages!) {
        String randomNumStr = Constants().generateRandomNumberString(8);
        final filename = '${supabase.auth.currentUser!.id}_$randomNumStr.png';

        final fileBytes = await File(image.path).readAsBytes();

        await supabase.storage.from('posts').uploadBinary(
              filename,
              fileBytes,
            );

        final publicUrl = supabase.storage.from('posts').getPublicUrl(filename);
        imgUrls.add(publicUrl);
      }

      final userId = supabase.auth.currentUser!.id;
      await supabase.from('posts').upsert({
        'author_id': userId,
        'content': _postController.text,
        'img_urls': imgUrls,
      });

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You've posted"),
      ));

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: ${e.toString()}')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(
            "Create Post",
            style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.bold),
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
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 4, right: 16, bottom: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0x70F30802),
                      fontSize: 12,
                      fontFamily: 'SF Pro Text',
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.30,
                    ),
                  ),
                ),
                if (isLoading) CircularProgressIndicator(),
                GestureDetector(
                  onTap: post,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Color(0xFFF30802),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: 6, horizontal: 16), // Optional padding
                    child: Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userAvatar.isNotEmpty)
                    Container(
                      width: 30,
                      height: 30,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: NetworkImage(userAvatar),
                          fit: BoxFit.fill,
                        ),
                        shape: OvalBorder(),
                      ),
                    ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      maxLines: 16,
                      controller: _postController,
                      decoration: InputDecoration(
                        hintText: "What’s happening?",
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      style: TextStyle(
                        color: Color(0xFF687684),
                        fontSize: 14,
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: cameraImage,
                      child: Image.asset(
                        "assets/images/post/camera.png",
                        fit: BoxFit.fill,
                        height: 64, // This is the height of the image
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 80, // Set your desired height here
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages!.length,
                          itemBuilder: (context, index) {
                            return Row(children: [
                              Image.file(File(_selectedImages![index].path),
                                  fit: BoxFit.fill, height: 64),
                              SizedBox(width: 8),
                            ]);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'assets/images/icons/picture.png',
                            width: 16,
                            height: 16,
                          ),
                          onPressed: pickImages,
                        ),
                        IconButton(
                          icon: Image.asset(
                            'assets/images/icons/gif.png',
                            width: 16,
                            height: 16,
                          ),
                          onPressed: () {
                            print('Image Icon Button Pressed');
                          },
                        ),
                        IconButton(
                          icon: Image.asset(
                            'assets/images/icons/chart.png',
                            width: 16,
                            height: 16,
                          ),
                          onPressed: () {
                            print('Image Icon Button Pressed');
                          },
                        ),
                        IconButton(
                          icon: Image.asset(
                            'assets/images/icons/location.png',
                            width: 16,
                            height: 16,
                          ),
                          onPressed: () {
                            print('Image Icon Button Pressed');
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'assets/images/icons/tick.png',
                            width: 16,
                            height: 16,
                          ),
                          onPressed: () {
                            print('Image Icon Button Pressed');
                          },
                        ),
                        IconButton(
                          icon: Image.asset(
                            'assets/images/icons/add.png',
                            width: 16,
                            height: 16,
                          ),
                          onPressed: () {
                            print('Image Icon Button Pressed');
                          },
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
