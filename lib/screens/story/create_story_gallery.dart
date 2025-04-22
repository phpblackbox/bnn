import 'dart:io';
import 'dart:typed_data';
import 'package:bnn/providers/story_provider.dart';
import 'package:bnn/utils/colors.dart';
import 'package:bnn/widgets/buttons/button-gradient-main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateStoryGallery extends StatefulWidget {
  const CreateStoryGallery({super.key});

  @override
  _CreateStoryGalleryState createState() => _CreateStoryGalleryState();
}

class _CreateStoryGalleryState extends State<CreateStoryGallery> {
  void showLoadingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFF30802)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Uploading your story...',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'SF Pro Text',
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please wait while we process your content',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'SF Pro Text',
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Create Story",
            style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20.0),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Consumer<StoryProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildButtons(context, provider),
                  provider.selectedImages.isNotEmpty
                      ? Expanded(
                          child: _buildImageGrid(provider),
                        )
                      : const Text(''),
                  const Spacer(),
                  _buildNextButton(provider, context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, StoryProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildImageSelectionButton("assets/images/post/camera0.png",
            () => provider.cameraImage(context)),
        _buildImageSelectionButton(
            "assets/images/post/gallery.png", () => provider.pickMedia()),
      ],
    );
  }

  Widget _buildImageSelectionButton(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image(
          image: AssetImage(imagePath),
          width: 100,
          height: 100,
        ),
      ),
    );
  }

  Widget _buildImageGrid(StoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: provider.selectedImages.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (BuildContext context, int index) {
          final fileType = provider.getFileType(provider.selectedImages[index].path);
          if (fileType == 'image') {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.file(
                File(provider.selectedImages[index].path),
                fit: BoxFit.cover,
              ),
            );
          } else if (fileType == 'video') {
            return FutureBuilder<Uint8List?>(
              future: provider.generateThumbnail(provider.selectedImages[index].path),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(strokeWidth: 2));
                } else if (snapshot.hasData && snapshot.data != null) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      )
                    ],
                  );
                } else {
                  return Center(child: Text('Failed to load thumbnail'));
                }
              },
            );
          } else {
            return Center(child: Text('Unsupported file'));
          }
        },
      ),
    );
  }

  Widget _buildNextButton(StoryProvider provider, BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        SizedBox(
          width: 120,
          child: ButtonGradientMain(
            label: 'Next',
            onPressed: () {
              showLoadingModal();
              provider.uploadStories(context);
            },
            textColor: Colors.white,
            gradientColors: [AppColors.primaryBlack, AppColors.primaryRed],
          ),
        ),
      ],
    );
  }
}
