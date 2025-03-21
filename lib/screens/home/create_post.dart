import 'dart:io';
import 'dart:typed_data';
import 'package:bnn/providers/auth_provider.dart';
import 'package:bnn/providers/post_provider.dart';
import 'package:bnn/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final List<String> images = [
    'assets/images/post/camera.png',
  ];

  final TextEditingController _postController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selected = [];
  List<XFile> _selectedVideos = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultipleMedia();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selected.addAll(pickedFiles);
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
          _selected.add(image);
        });
      }
    } catch (e) {
      CustomToast.showToastDangerTop(
          context, 'No camera found. Please check your device settings.');
    }
  }

  Future<void> post(PostProvider postProvider) async {
    if (_postController.text.isEmpty) {
      CustomToast.showToastWarningTop(
          context, 'Please describe what’s happening');

      return;
    }
    try {
      await postProvider.newPost(context, _selected, _postController.text);
      CustomToast.showToastSuccessTop(context, "You've posted successfully!");
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      CustomToast.showToastDangerTop(
          context, 'Error uploading image: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context);
    final meProfile = authProvider.profile!;

    final PostProvider postProvider = Provider.of<PostProvider>(context);

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
                if (postProvider.loading) CircularProgressIndicator(),
                GestureDetector(
                  onTap: () => post(postProvider),
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
                  if (meProfile.id != null)
                    Container(
                      width: 30,
                      height: 30,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: NetworkImage(meProfile.avatar!),
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
                        height: 64,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selected.length,
                          itemBuilder: (context, index) {
                            final fileType =
                                postProvider.getFileType(_selected[index].path);
                            return Row(children: [
                              fileType == "image"
                                  ? Image.file(File(_selected[index].path),
                                      fit: BoxFit.fill, height: 64)
                                  : FutureBuilder<Uint8List?>(
                                      future: postProvider.generateThumbnail(
                                          _selected[index].path),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return Image.memory(snapshot.data!);
                                        } else {
                                          return Text(
                                              'Failed to load thumbnail');
                                        }
                                      },
                                    ),
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
                          onPressed: () {},
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
