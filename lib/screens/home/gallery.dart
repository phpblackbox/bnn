import 'dart:io';
import 'dart:typed_data';

import 'package:bnn/main.dart';
import 'package:bnn/screens/home/createStory.dart';
import 'package:bnn/screens/signup/ButtonGradientMain.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Galley extends StatefulWidget {
  const Galley({Key? key}) : super(key: key);

  @override
  _GalleyState createState() => _GalleyState();
}

class _GalleyState extends State<Galley> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages = [];
  bool isLoading = false;

  Future<void> pickImages() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
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

  Future<void> uploadImages() async {
    if (_selectedImages!.length > 0) {
      setState(() {
        isLoading = true;
      });
      List img_urls = [];
      try {
        for (var image in _selectedImages!) {
          String randomNumStr = Constants().generateRandomNumberString(8);
          final filename =
              '${supabase.auth.currentUser!.id}_${randomNumStr}.png';

          final fileBytes = await File(image.path).readAsBytes();

          await supabase.storage.from('story').uploadBinary(
                filename,
                fileBytes,
              );

          final publicUrl =
              supabase.storage.from('story').getPublicUrl(filename);
          img_urls.add(publicUrl);
        }

        setState(() {
          isLoading = false;
        });

        final userId = supabase.auth.currentUser!.id;
        await supabase.from('stories').upsert({
          'author_id': userId,
          'img_urls': img_urls,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Images have been uploaded!'),
        ));

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CreateStory()));
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            child: Text(
              "Create Story",
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
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: cameraImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          10.0), // Adjust the radius as needed
                      child: Image(
                          image: AssetImage("assets/images/post/camera0.png"),
                          width: 100,
                          height: 100),
                    ),
                  ),
                  GestureDetector(
                    onTap: pickImages,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          10.0), // Adjust the radius as needed
                      child: Image(
                          image: AssetImage("assets/images/post/gallery.png"),
                          width: 100,
                          height: 100),
                    ),
                  ),
                ],
              ),
              _selectedImages != null && _selectedImages!.isNotEmpty
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                            itemCount: _selectedImages!.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Adjust the radius as needed
                                child: Image.file(
                                  File(_selectedImages![index].path),
                                  fit: BoxFit.cover,
                                ),
                              );
                            }),
                      ),
                    )
                  : Text(''),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              Spacer(),
              Row(
                children: [
                  Spacer(), // This pushes the button to the right
                  SizedBox(
                    width: 120, // Set your desired width here
                    child: ButtonGradientMain(
                      label: 'Next',
                      onPressed: () {
                        uploadImages();
                      },
                      textColor: Colors.white,
                      gradientColors: [Color(0xFF000000), Color(0xFF820200)],
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
