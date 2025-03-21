import 'dart:io';
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
                    'please wait while we process your post',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'SF Pro Text',
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w400,
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
                  _buildImageSelectionRow(context, provider),
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

  Widget _buildImageSelectionRow(BuildContext context, StoryProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildImageSelectionButton("assets/images/post/camera0.png",
            () => provider.cameraImage(context)),
        _buildImageSelectionButton(
            "assets/images/post/gallery.png", () => provider.pickImages()),
        _buildImageSelectionButton("assets/images/post/video.png", () async {
          showLoadingModal();
          await provider.uploadVideo(context);
        }),
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
          return ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.file(
              File(provider.selectedImages[index].path),
              fit: BoxFit.cover,
            ),
          );
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
              provider.uploadImages(context);
            },
            textColor: Colors.white,
            gradientColors: [AppColors.primaryBlack, AppColors.primaryRed],
          ),
        ),
      ],
    );
  }
}
